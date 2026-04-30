import Foundation
@preconcurrency import AVFAudio
import MediaPlayer
import SwiftUI
import Observation

@Observable @MainActor final public class MusicPlayer {
    /// instance
    public static let shared: MusicPlayer = .init()
    
    /// Engine and Nodes
    /// AVFAudio側の型は非Sendableだが、内部はthread-safeなのでoffline render時に
    /// background queueから触れるよう nonisolated(unsafe) を付与する
    private nonisolated(unsafe) let audioEngine: AVAudioEngine = .init()
    private nonisolated(unsafe) let playerNode: AVAudioPlayerNode = .init()
    private nonisolated(unsafe) let pitchControl: AVAudioUnitTimePitch = .init()
    private nonisolated(unsafe) let reverb: AVAudioUnitReverb = .init()
    private var audioFile: AVAudioFile?
    
    /// 再生時刻保持用のObservable(高頻度更新を局所化)
    public let time: MPPlaybackTime = .init()

    /// return true if playable
    private var isEnableAudio: Bool {
        return audioFile != nil
    }
    
    private var currentTimeTimer: Timer?
    
    /// Threshold value whether return to the previous song
    /// value is seconds
    private static let backSameMusicThreshold: Float = 2.0
    
    /// index of current playing MPMediaItem
    private var currentIndex: Int {
        get { itemList.currentIndex }
        set { itemList.currentIndex = newValue }
    }
    
    /// If true, the current Time exceeds the song playback time
    private var isSeekOver: Bool {
        return time.currentTime >= maxPlaybackTime
    }
    
    // バックグラウンド時の再生時に表示するデフォルトのアイコン
    public var defaultBgIcon: UIImage?
    
    /// item duration
    public var duration: TimeInterval? {
        return currentItem?.duration
    }
    public var fDuration: Float {
        return Float(duration ?? 0.0)
    }
    
    /// current playback item
    public var currentItem: MPSongItem? {
        return itemList.currentItem
    }
    
    /// Current time timer schedule time
    /// The smaller the value, the narrower the interval between the calculation of the current playback time.
    /// Do not set too small a number from a performance standpoint.
    /// Set a value greater than 0.
    public var currentTimeTimerScheduleTime: Float = 0.25 {
        didSet {
            stopCurrentTimeRendering()
            startCurrentTimeRendering()
        }
    }
    
    /// playback items
    private(set) public var itemList: MPSongItemList = .init()
    private(set) public var items: [MPSongItem] {
        get { return itemList.items }
        set { itemList = .init(items: newValue, currentIndex: currentIndex) }
    }
    private var originalItems: [MPSongItem] = []
    
    /// true is player is playing
    private(set) public var isPlaying: Bool = false

    /// Pitch
    public var pitch: Float = MPConstants.defaultPitchValue {
        didSet {
            self.pitchControl.pitch = MusicPlayerService.enablePitchValue(value: self.pitch)
        }
    }
    public var pitchOptions: MusicEffectRangeOption = .init(minValue: MPConstants.defaultPitchMinValue,
                                                                       maxValue: MPConstants.defaultPitchMaxValue,
                                                                       unit: MPConstants.defaultPitchUnit,
                                                                       defaultValue: MPConstants.defaultPitchValue)
    
    /// Rate
    public var rate: Float = MPConstants.defaultRateValue {
        didSet {
            self.pitchControl.rate = MusicPlayerService.enableRateValue(value: self.rate)
            self.startCurrentTimeRendering(currentRate: self.rate)
        }
    }
    public var rateOptions: MusicEffectRangeOption = .init(minValue: MPConstants.defaultRateMinValue,
                                                                      maxValue: MPConstants.defaultRateMaxValue,
                                                                      unit: MPConstants.defaultRateUnit,
                                                                      defaultValue: MPConstants.defaultRateValue)
    /// Reverb
    public var reverbValue: Float = MPConstants.defaultReverbValue {
        didSet {
            if let _ = self.reverbType {
                self.reverb.wetDryMix = self.reverbValue
            }
            else {
                self.reverb.wetDryMix = 0
            }
        }
    }
    public var reverbType: AVAudioUnitReverbPreset? {
        didSet {
            if let unwrappedValue = self.reverbType {
                self.reverb.wetDryMix = self.reverbValue
                self.reverb.loadFactoryPreset(unwrappedValue)
            }
            else {
                self.reverb.wetDryMix = 0
            }
        }
    }
    public var reverbOptions: MusicEffectRangeOption = .init(minValue: MPConstants.limitReverbMinValue,
                                                                        maxValue: MPConstants.limitReverbMaxValue,
                                                                        unit: MPConstants.defaultReverbUnit,
                                                                        defaultValue: MPConstants.defaultReverbValue)
    
    /// trimming(seconds) and divisions
    public var playbackTimeRange: ClosedRange<Float>? {
        didSet {
            if playbackTimeRange != nil {
                division.clear()
            }
            
            if let timeRange = playbackTimeRange {
                let min = timeRange.lowerBound
                let max = timeRange.upperBound
                if self.time.currentTime < min {
                    self.setSeek(seconds: min)
                }
                else if self.time.currentTime > max {
                    self.setSeek(seconds: max)
                }
            }
        }
    }
    
    public var division: MPDivision = .init(currentTime: 0.0, loopDivision: false) {
        didSet {
            if division.isEmpty == false {
                playbackTimeRange = nil
            }
        }
    }
    
    public var trimmingType: MPTrimmingType {
        if playbackTimeRange != nil {
            return .trimming
        }
        else if !division.isEmpty {
            return .division
        }
        return .none
    }
    
    // 再生できる最小の秒数
    private var minPlaybackTime: Float {
        if let playbackTimeRange = playbackTimeRange {
            return playbackTimeRange.lowerBound
        }
        return division.fromValue(duration: fDuration)
    }
    // seekできる最小の秒数
    private var minSeekTime: Float {
        if let min = playbackTimeRange {
            return min.lowerBound
        }
        return 0.0
    }
    // 閾値を含んだ再生できる最小の秒数
    private var minThresholdPlaybackTime: Float {
        return minPlaybackTime + MusicPlayer.backSameMusicThreshold
    }
    
    // 再生できる最大の秒数
    private var maxPlaybackTime: Float {
        if let max = playbackTimeRange?.upperBound {
            return max
        }
        return division.toValue(duration: fDuration)
    }
    // seekできる最大の秒数
    private var maxSeekTime: Float {
        if let max = playbackTimeRange?.upperBound {
            return max
        }
        return fDuration
    }
    
    // export中かどうかのフラグ
    private var isExporting = false
    
    /// shuffle
    public var isShuffle: Bool = false {
        didSet {
            if self.isShuffle {
                self.shuffle()
            }
            else {
                self.setOriginalSort()
            }
        }
    }
    
    /// repeat
    public var repeatType: MPRepeatType = .none
    
    /// remote command
    public var rightRemoteCommand: MPRemoteCommandType = .nextTrack {
        didSet {
            self.setLeftAndRightRemoteCommandValue(rightCommand: self.rightRemoteCommand)
        }
    }
    public var leftRemoteCommand: MPRemoteCommandType = .previousTrack {
        didSet {
            self.setLeftAndRightRemoteCommandValue(leftCommand: self.leftRemoteCommand)
        }
    }
    
    /// skip seconds on remote command
    public var remoteSkipSeconds: Int = 5 {
        didSet {
            self.setLeftAndRightRemoteCommandValue(skipSeconds: self.remoteSkipSeconds)
        }
    }
    
    private init() {
        setNotification()
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchControl)
        audioEngine.attach(reverb)
        initRemoteCommand()
    }
    
    deinit {
        // 実態はsingletonでありdeinitされない。
        // MainActor隔離下ではdeinitからstop()を呼べないので呼ばない
        // (AVAudioEngineは自身のdeinitで停止する)
        NotificationCenter.default.removeObserver(self)
    }
}

public extension MusicPlayer {
    func export(song: MPSongItem, onSuccess: @escaping (_ exportUrlPath: String) -> Void, onError: @escaping () -> Void) {
        if isExporting { return }
        guard let assetURL = song.item.assetURL else { return }
        guard let sourceFile = try? AVAudioFile(forReading: assetURL) else { return }
        isExporting = true
        stop()
        setCurrentItem(items: [song], index: 0)
        setCurrentEffect(effect: song.effect, trimming: song.trimming, division: song.division)
        _ = setScheduleFile(assetURL: assetURL)
        let trimmingStart = song.trimming?.trimming.lowerBound
        if let trimmingStart = trimmingStart {
            setSeek(seconds: trimmingStart, withPlay: false)
        }

        let format = sourceFile.processingFormat
        let maxFrameCount: AVAudioFrameCount = 4096

        do {
            try audioEngine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: maxFrameCount)
            try audioEngine.start()
            playerNode.play()
        }
        catch(let e) {
            print(e)
            onError()
        }

        // MainActor隔離下の値を事前算出してbackground queueに渡す
        let dDuration = duration ?? 0.0
        let trimmingLower = song.trimming?.trimming.lowerBound
        let trimmingUpper = song.trimming?.trimming.upperBound
        let songRate = song.effect?.rate ?? 1.0

        Self.performExport(audioEngine: audioEngine,
                           sourceFile: sourceFile,
                           duration: dDuration,
                           trimmingLower: trimmingLower,
                           trimmingUpper: trimmingUpper,
                           songRate: songRate) { [weak self] result in
            Task { @MainActor in
                guard let self = self else { return }
                switch result {
                case .success(let path):
                    self.isExporting = false
                    self.stop()
                    self.audioEngine.disableManualRenderingMode()
                    self.resetPlaybackTime()
                    if let trimmingStart = trimmingStart {
                        self.setSeek(seconds: trimmingStart, withPlay: false)
                    }
                    onSuccess(path)
                case .failure(let e):
                    self.isExporting = false
                    print(e)
                    onError()
                }
            }
        }
    }

    /// オフラインレンダリングをbackground queueで実行する
    /// MainActor隔離外で動かすため、必要な値はすべて引数で受け取る
    private nonisolated static func performExport(audioEngine: AVAudioEngine,
                                                  sourceFile: AVAudioFile,
                                                  duration: TimeInterval,
                                                  trimmingLower: Float?,
                                                  trimmingUpper: Float?,
                                                  songRate: Float,
                                                  completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .default).async {
            do {
                let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat, frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!

                // 出力先のファイル
                let path = NSTemporaryDirectory() + "neon_music.m4a"
                let url = URL(string: path)!
                let outputFile = try AVAudioFile(forWriting: url, settings: sourceFile.fileFormat.settings)

                // exportする曲の秒数を取得する
                var songLength = Double(sourceFile.length)
                // trimmingの開始の分だけ秒数を減らす
                let startTrimmingDiff = Double(trimmingLower ?? 0.0)
                songLength = songLength - startTrimmingDiff * sourceFile.fileFormat.sampleRate
                // trimmingの終了の分だけ秒数を減らす
                if let trimmingUpper = trimmingUpper {
                    let endTrimmingDiff = duration - Double(trimmingUpper)
                    songLength = songLength - endTrimmingDiff * sourceFile.fileFormat.sampleRate
                }
                // Rateに応じた曲の長さを基準値とする
                let sSongLength = AVAudioFramePosition(songLength / Double(songRate))

                while audioEngine.manualRenderingSampleTime < sSongLength {
                    let frameCount = sSongLength - audioEngine.manualRenderingSampleTime
                    let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)
                    let status = try audioEngine.renderOffline(framesToRender, to: buffer)

                    switch status {
                    case .success:
                        try outputFile.write(from: buffer)
                    case .insufficientDataFromInputNode:
                        // Applicable only when using the input node as one of the sources.
                        break
                    case .cannotDoInCurrentContext:
                        // The engine couldn't render in the current render call.
                        // Retry in the next iteration.
                        break
                    case .error:
                        // An error occurred while rendering the audio.
                        fatalError("The manual rendering failed.")
                    @unknown default:
                        fatalError("unknown error.")
                    }
                }
                completion(.success(path))
            } catch(let e) {
                completion(.failure(e))
            }
        }
    }
}

public extension MusicPlayer {
    /// Play current item
    func play() {
        if isSeekOver || !isEnableAudio {
            return
        }
        
        setAudioSession()
        
        do {

            try audioEngine.start()
            playerNode.play()
            isPlaying = true
            startCurrentTimeRendering()
            setNowPlayingInfo()
        }
        catch let e {
            print(e.localizedDescription)
        }
    }
    
    /// Play and set items
    /// - Parameters:
    ///   - items: playback items
    ///   - index: item index
    func play(items: [MPSongItem], index: Int) {
        if !itemsSafe(items: items, index: index) {
            return
        }
        setCurrentItem(items: items, index: index)
        resetPlaybackTime()
        if isShuffle {
            shuffle()
        }
        if !setScheduleFile() {
            stop()
            return
        }
        setCurrentEffect(effect: currentItem?.effect,
                         trimming: currentItem?.trimming,
                         division: currentItem?.division)
        play()
    }
    
    /// Play by id
    /// - Parameter id: item id
    func play(id: MPMediaEntityPersistentID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        currentIndex = index
        resetPlaybackTime()
        if !setScheduleFile() {
            stop()
            return
        }
        setCurrentEffect(effect: currentItem?.effect,
                         trimming: currentItem?.trimming,
                         division: currentItem?.division)
        play()
    }
    
    // Set Current Item
    func setCurrentItem(items: [MPSongItem], index: Int) {
        self.originalItems = items
        self.items = items
        self.currentIndex = index
    }
    
    /// Play next item
    /// forwardEnableSong: if true, advance index to valid song
    func next(forwardEnableSong: Bool = false) {
        // if there is a Division, move to that number of seconds
        if !division.isEmpty {
            let nextDivision = division.toValue(duration: fDuration)
            if nextDivision < fDuration {
                setSeek(seconds: nextDivision)
                division.setCurrentIndex(currentTime: time.currentTime)
                return
            }
        }
        
        var nextIndex = currentIndex + 1
        let isSafe = itemsSafe(index: nextIndex)
        switch repeatType {
        case .list:
            // restart
            if !isSafe {
                nextIndex = 0
                
                // reshuffle
                if isShuffle {
                    items = originalItems.shuffled()
                }
            }
        case .one:
            if !isSafe {
                setSeek(seconds: 0)
                return
            }
        case .none:
            if !isSafe {
                pause()
                return
            }
        }
        currentIndex = nextIndex
        resetPlaybackTime()
        if !setScheduleFile() {
            if !forwardEnableSong {
                stop()
                return
            }
            guard let enableMusicIndex = enableMusicIndex(forward: true) else {
                stop()
                return
            }
            currentIndex = enableMusicIndex
            _ = setScheduleFile()
        }
        setCurrentEffect(effect: currentItem?.effect,
                         trimming: currentItem?.trimming,
                         division: currentItem?.division)
        play()
    }
    
    /// Play previous item
    /// backEnableSong: Whether to return to the previous song when the previous song cannot be played
    func back(backEnableSong: Bool = false) {
        if !division.isEmpty {
            // 戻る時間を取得する
            if let backTime = division.backTime(currentTime: time.currentTime, threshold: MusicPlayer.backSameMusicThreshold) {
                // 戻れるかどうか
                if backTime <= time.currentTime {
                    // 戻る
                    setSeek(seconds: backTime)
                    division.setCurrentIndex(currentTime: backTime)
                    return
                }
            }
        }
        else {
            if time.currentTime >= minThresholdPlaybackTime {
                setSeek(seconds: minPlaybackTime)
                return
            }
        }
        
        let nextIndex = currentIndex - 1
        if !itemsSafe(index: nextIndex) {
            return
        }
        currentIndex = nextIndex
        resetPlaybackTime()
        if !setScheduleFile() {
            if !backEnableSong {
                stop()
                return
            }
            guard let enableMusicIndex = enableMusicIndex(forward: false) else {
                stop()
                return
            }
            currentIndex = enableMusicIndex
            _ = setScheduleFile()
        }
        setCurrentEffect(effect: currentItem?.effect,
                         trimming: currentItem?.trimming,
                         division: currentItem?.division)
        play()
    }
    
    /// Pause playback
    func pause() {
        updateCurrentTime()
        audioEngine.pause()
        playerNode.pause()
        isPlaying = false
        setNowPlayingInfo()
        stopCurrentTimeRendering()
    }
    
    /// change current playback position
    /// - Parameter withPlay: true if playback is performed after the position is changed
    func setSeek(withPlay: Bool? = nil) {
        // range外の再生時間でseekしようとした場合はrange内に収めてから行うようにする
        // 同値書き込みでも @Observable 通知が発火するため、無駄な伝搬を抑制する
        let clamped = min(max(minSeekTime, time.currentTime), maxSeekTime)
        if time.currentTime != clamped {
            time.currentTime = clamped
        }
        let seekTime = TimeInterval(time.currentTime)
        let isPlay = withPlay ?? isPlaying
        guard let duration = duration else { return }
        guard let audioFile = audioFile else { return }
        if seekTime > duration { return }

        let sampleRate = audioFile.processingFormat.sampleRate
        var startSampleTime = AVAudioFramePosition(sampleRate * seekTime)
        // 0秒より前にseekしようとしたら0秒にする
        if (startSampleTime < 0) { startSampleTime = 0 }

        var length = duration - seekTime
        if length <= 0 { length = 0 }
        var remainSampleTime = AVAudioFrameCount(length * Double(sampleRate))
        if remainSampleTime <= 0 { remainSampleTime = 1 }   // 0だとクラッシュするので極小値で対応

        time.cachedSeekBarSeconds = Float(seekTime)

        stop()

        playerNode.scheduleSegment(audioFile, startingFrame: startSampleTime, frameCount: remainSampleTime, at: nil)

        setNowPlayingInfo()

        // divisionタイプならseekした時間でindexを更新しておく
        if trimmingType == .division {
            division.setCurrentIndex(currentTime: time.currentTime)
        }

        if isPlay {
            play()
        }
    }

    /// change current playback position
    /// - Parameters:
    ///   - seconds: move seconds time
    ///   - withPlay: with play
    func setSeek(seconds: Float, withPlay: Bool? = nil) {
        time.currentTime = seconds
        setSeek(withPlay: withPlay)
    }

    /// change current playback position
    /// - Parameters:
    ///   - addingSeconds: adding seconds time
    ///   - withPlay: with play
    func setSeek(addingSeconds: Float, withPlay: Bool? = nil) {
        time.currentTime += addingSeconds
        setSeek(withPlay: withPlay)
    }
    
    /// increment playback pitch
    func incrementPitch() {
        pitch = incrementedPitch()
    }
    func incrementedPitch(startPitch: Float? = nil) -> Float {
        let startPitch = startPitch ?? pitch
        if startPitch >= pitchOptions.maxValue {
            return startPitch
        }
        return startPitch + pitchOptions.unit
    }
    
    /// decrement playback pitch
    func decrementPitch() {
        pitch = decrementedPitch()
    }
    func decrementedPitch(startPitch: Float? = nil) -> Float {
        let startPitch = startPitch ?? pitch
        if startPitch <= pitchOptions.minValue {
            return startPitch
        }
        return startPitch - pitchOptions.unit
    }
    
    /// reset playback pitch
    func resetPitch() {
        pitch = pitchOptions.defaultValue
    }
    
    /// increment playback rate
    func incrementRate() {
        rate = incrementedRate()
    }
    func incrementedRate(startRate: Float? = nil) -> Float {
        let startRate = startRate ?? rate
        if startRate >= rateOptions.maxValue {
            return startRate
        }
        return startRate + rateOptions.unit
    }
    
    /// decrement playback rate
    func decrementRate() {
        rate = decrementedRate()
    }
    func decrementedRate(startRate: Float? = nil) -> Float {
        let startRate = startRate ?? rate
        if startRate <= rateOptions.minValue {
            return startRate
        }
        return startRate - rateOptions.unit
    }
    
    /// reset playback rate
    func resetRate() {
        rate = rateOptions.defaultValue
    }
    
    /// set timer
    /// currentRate: current playback rate
    func startCurrentTimeRendering(currentRate: Float? = nil) {
        // エクスポート中は再生時間を更新する必要はない
        if isExporting { return }

        if currentTimeTimer?.isValid == true {
            stopCurrentTimeRendering()
        }
        let rate = currentRate ?? rate
        let valueRate = rate / MPConstants.defaultRateValue
        let value = currentTimeTimerScheduleTime / valueRate
        // .commonモードで登録することで、UIトラッキング中(スクロールやSlider操作中など)も
        // タイマーが発火し続け、currentTimeがアプリケーション側に伝搬され続けるようにする
        let timer = Timer(timeInterval: TimeInterval(value), target: self, selector: #selector(self.onUpdateCurrentTime), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        currentTimeTimer = timer
    }

    /// stop timer
    func stopCurrentTimeRendering() {
        currentTimeTimer?.invalidate()
        currentTimeTimer = nil
    }
    
    /// move item
    /// - Parameters:
    ///   - fromOffsets: from item offsets
    ///   - toOffset: to item offset
    func moveItem(fromOffsets: IndexSet, toOffset: Int) {
        guard let preId = currentItem?.id else { return }
        let index = currentIndex+1
        let prefixItems = Array(items[0 ..< index])
        var suffixItems = Array(items[index ..< items.count])
        suffixItems.move(fromOffsets: IndexSet(fromOffsets), toOffset: toOffset)
        items = prefixItems + suffixItems
        currentIndex = items.firstIndex(where: { $0.id == preId })!
    }
    
    /// update song effect
    /// - Parameters:
    ///   - songId: song id
    ///   - effect: effect
    ///   - trimming: trimming
    ///   - divisions: divisions
    ///   - title: title
    ///   - lyrics: lyrics
    func updateSongEffect(songId: UInt64,
                          effect: MPSongItemEffect? = nil,
                          trimming: ClosedRange<Float>? = nil,
                          divisions: [Float]? = nil,
                          isLoopDivision: Bool? = nil,
                          title: String? = nil,
                          lyrics: String? = nil) {
        var newItems = items
        applyEffect(to: &newItems,
                    songId: songId,
                    effect: effect,
                    trimming: trimming,
                    divisions: divisions,
                    title: title,
                    lyrics: lyrics)
        items = newItems
        applyEffect(to: &originalItems,
                    songId: songId,
                    effect: effect,
                    trimming: trimming,
                    divisions: divisions,
                    title: title,
                    lyrics: lyrics)
        let isCurrentItem = songId == currentItem?.id
        if isCurrentItem {
            rate = effect?.rate ?? rate
            pitch = effect?.pitch ?? pitch
            if let reverb = effect?.reverb {
                reverbValue = reverb.value
                reverbType = reverb.type
            }
            
            playbackTimeRange = trimming
            if let divisions = divisions {
                division = .init(values: divisions, currentTime: time.currentTime, loopDivision: isLoopDivision)
            }
        }
    }
    
    /// set current effect
    /// - Parameters:
    ///   - effect: effect
    ///   - trimming: trimming effect
    ///   - divisions: divisions
    func setCurrentEffect(effect: MPSongItemEffect?,
                          trimming: MPSongItemTrimming?,
                          division: MPDivision?) {
        if let effect = effect {
            rate = effect.rate
            pitch = effect.pitch
            if let reverb = effect.reverb {
                reverbType = reverb.type
                reverbValue = reverb.value
            }
        }
        if let trimming = trimming {
            playbackTimeRange = trimming.trimming
        }
        if let division = division {
            self.division = division
            self.division.setCurrentIndex(currentTime: time.currentTime)
        }
    }
    
    /// reset song effects
    func resetCurrentEffects() {
        resetRate()
        resetPitch()
        playbackTimeRange = nil
        division.clear()
    }
    
    /// reset effects by song id
    /// - Parameter songId: song id
    func resetEffects(songId: UInt64) {
        var newItems = items
        guard let index = newItems.firstIndex(where: { $0.id == songId }) else { return }
        newItems[index].effect = .init(rate: rateOptions.defaultValue, pitch: pitchOptions.defaultValue, reverb: .init(value: reverbOptions.defaultValue, type: nil))
        newItems[index].trimming = nil
        newItems[index].division = nil
        items = newItems
    }
    
    /// add division
    /// - Parameter seconds: division seconds
    func addDivision(seconds: Float) {
        division.add(seconds: seconds)
        division.setCurrentIndex(currentTime: time.currentTime)
    }

    /// remove division
    /// - Parameter index: remove index
    func removeDivision(index: Int) {
        division.remove(index: index)
        division.setCurrentIndex(currentTime: time.currentTime)
    }
}

private extension MusicPlayer {
    
    /// set audio session
    func setAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        }
        catch let e {
            print(e.localizedDescription)
        }
    }
    
    /// get enable music index
    /// - Parameter forward: if true, search forward
    /// - Returns: enable music index
    func enableMusicIndex(forward: Bool) -> Int? {
        let from = forward ? currentIndex : 0
        let to = forward ? items.count-1 : currentIndex
        if !items.indices.contains(from) || !items.indices.contains(to) { return nil }
        let array = items[from...to]
        var newIndex: Int?
        if forward {
            newIndex = array.firstIndex(where: { $0.item.assetURL != nil })
        }
        else {
            newIndex = array.lastIndex(where: { $0.item.assetURL != nil })
        }
        return newIndex
    }
    
    /// apply effect to a songs array (struct value semantics)
    /// - Parameters:
    ///   - songs: songs (inout)
    ///   - songId: song id
    ///   - effect: effect
    ///   - trimming: trimming
    ///   - divisions: divisions
    ///   - title: title
    ///   - lyrics: lyrics
    func applyEffect(to songs: inout [MPSongItem],
                     songId: UInt64,
                     effect: MPSongItemEffect?,
                     trimming: ClosedRange<Float>?,
                     divisions: [Float]?,
                     title: String? = nil,
                     lyrics: String? = nil) {
        guard let index = songs.firstIndex(where: { $0.id == songId }) else { return }
        if let effect = effect {
            songs[index].effect = .init(rate: effect.rate, pitch: effect.pitch, reverb: effect.reverb)
        }
        if let trimming = trimming {
            songs[index].trimming = .init(trimming: trimming)
        }
        if let divisions = divisions {
            let baseTime = songId == currentItem?.id ? time.currentTime : 0.0
            songs[index].division = .init(values: divisions, currentTime: baseTime)
        }
        if let title = title {
            songs[index].title = title
        }
        if let lyrics = lyrics {
            songs[index].lyrics = lyrics
        }
    }
    
    /// update current playback time
    func updateCurrentTime() {
        // 最後にサンプリングしたデータを取得する
        guard let nodeTime = playerNode.lastRenderTime else { return }
        // playerNodeの時間軸に変換する
        guard let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else { return }
        // サンプルレートとサンプルタイム取得
        let sampleRate = playerTime.sampleRate
        let sampleTime = playerTime.sampleTime
        // 秒数を取得する
        let seconds = Double(sampleTime) / sampleRate
        // シークバーを動かした後は内部的にsampleTimeが0にリセットされるため
        // 前回の再生時間を足す
        let newCurrentTime = Float(seconds) + time.cachedSeekBarSeconds
        let clamped = min(newCurrentTime, fDuration)
        // 同じ値の代入で@Observable通知が発火するのを抑制する
        if time.currentTime != clamped {
            time.currentTime = clamped
        }
    }

    /// stop playback
    func stop() {
        audioEngine.stop()
        playerNode.stop()
        isPlaying = false
    }
    
    /// check safe index
    /// - Parameters:
    ///   - items: playback list
    ///   - index: index
    /// - Returns: return true if index is safe
    func itemsSafe(items: [MPSongItem]? = nil, index: Int) -> Bool {
        let checkItems = items ?? self.items
        return checkItems.indices.contains(index)
    }
    
    /// set notification
    func setNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onInterruption(_:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onAudioSessionRouteChanged(_:)),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: nil)
    }
    
    /// set left and right remote command
    /// if command type is skip, set skip seconds
    /// - Parameters:
    ///   - leftCommand: left command
    ///   - rightCommand: right command
    ///   - skipSeconds: skip seconds
    func setLeftAndRightRemoteCommandValue(leftCommand: MPRemoteCommandType? = nil,
                                           rightCommand: MPRemoteCommandType? = nil,
                                           skipSeconds: Int? = nil) {
        let commandCenter = MPRemoteCommandCenter.shared()
        let leftCommand: MPRemoteCommandType = leftCommand ?? self.leftRemoteCommand
        let rightCommand: MPRemoteCommandType = rightCommand ?? self.rightRemoteCommand
        let skipSeconds: Int = skipSeconds ?? self.remoteSkipSeconds
        commandCenter.previousTrackCommand.isEnabled = !leftCommand.isSkipType
        commandCenter.nextTrackCommand.isEnabled = !rightCommand.isSkipType
        
        commandCenter.skipForwardCommand.isEnabled = rightCommand.isSkipType
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(integerLiteral: skipSeconds)]
        
        commandCenter.skipBackwardCommand.isEnabled = leftCommand.isSkipType
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(integerLiteral: skipSeconds)]
    }
    
    /// set RemoteCommand
    /// call only once
    func initRemoteCommand() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(self)
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            play()
            return .success
        }
        
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            pause()
            return .success
        }
        
        commandCenter.previousTrackCommand.removeTarget(self)
        commandCenter.previousTrackCommand.isEnabled = !leftRemoteCommand.isSkipType
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            back(backEnableSong: true)
            return .success
        }
        
        commandCenter.nextTrackCommand.removeTarget(self)
        commandCenter.nextTrackCommand.isEnabled = !rightRemoteCommand.isSkipType
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            next(forwardEnableSong: true)
            return .success
        }
        
        commandCenter.skipForwardCommand.removeTarget(self)
        commandCenter.skipForwardCommand.isEnabled = rightRemoteCommand.isSkipType
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(integerLiteral: remoteSkipSeconds)]
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            setSeek(addingSeconds: Float(remoteSkipSeconds))
            return .success
        }
        
        commandCenter.skipBackwardCommand.removeTarget(self)
        commandCenter.skipBackwardCommand.isEnabled = leftRemoteCommand.isSkipType
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(integerLiteral: remoteSkipSeconds)]
        commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
            setSeek(addingSeconds: Float(-remoteSkipSeconds))
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.removeTarget(self)
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard let positionCommandEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            setSeek(seconds: Float(positionCommandEvent.positionTime))
            return .success
        }
    }
    
    /// set nowPlayingInfo
    func setNowPlayingInfo() {
        let center = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = center.nowPlayingInfo ?? [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentItem?.displayTitle
        
        let size = CGSize(width: 50, height: 50)
        if let image = currentItem?.artwork?.image(at: size) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
        }
        else if let defaultBgIcon = defaultBgIcon {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: size) { _ in
                return defaultBgIcon
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time.currentTime
        
        if isPlaying {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
        }
        else {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        }
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        
        // Set the metadata
        center.nowPlayingInfo = nowPlayingInfo
    }
    
    /// set Schedule File
    func setScheduleFile(assetURL: URL? = nil) -> Bool {
        audioFile = nil
        guard let assetURL = assetURL ?? currentItem?.item.assetURL else { return false }
        do {
            audioFile = try AVAudioFile(forReading: assetURL)
            audioEngine.connect(playerNode, to: pitchControl, format: nil)
            audioEngine.connect(pitchControl, to: reverb, format: nil)
            audioEngine.connect(reverb, to: audioEngine.mainMixerNode, format: nil)
            playerNode.scheduleFile(audioFile!, at: nil)
            return true
        }
        catch let e {
            print(e.localizedDescription)
            return false
        }
    }
    
    /// shuffle items
    /// make currentItem the first element and shuffle the rest
    func shuffle() {
        guard let currentItemId = currentItem?.id else { return }
        var shuffled = items.shuffled()
        guard let currentItemIndex = shuffled.firstIndex(where: { $0.id == currentItemId }) else { return }
        shuffled.move(fromOffsets: [currentItemIndex], toOffset: 0)
        itemList = .init(items: shuffled, currentIndex: 0)
    }
    
    /// set original sort
    func setOriginalSort() {
        guard let originalIndex = originalItems.firstIndex(where: { $0.id == currentItem?.id }) else { return }
        itemList = .init(items: originalItems, currentIndex: originalIndex)
    }
    
    /// reset playback time
    func resetPlaybackTime() {
        time.cachedSeekBarSeconds = 0
        time.currentTime = 0
        playbackTimeRange = 0.0...fDuration
    }
}

private extension MusicPlayer {
    /// current time timer handler
    @objc private func onUpdateCurrentTime() {
        if isSeekOver {
            if trimmingType == .division {
                // ループする場合
                if division.loopDivision {
                    // divisionの境界線の前まで移動した状態でbackTimeを取得する
                    // MusicPlayer.backSameMusicThresholdでなくてもいい
                    if let back = division.backTime(currentTime: time.currentTime, threshold: MusicPlayer.backSameMusicThreshold) {
                        setSeek(seconds: back)
                    }
                }
                else {
                    // 最後まで到達した
                    if time.currentTime >= maxSeekTime {
                        if repeatType == .one {
                            setSeek(seconds: 0)
                        }
                        else {
                            next(forwardEnableSong: true)
                        }
                    }
                    else {
                        // divisionを越えたら区間のindexを更新する
                        division.setCurrentIndex(currentTime: time.currentTime)
                    }
                }
            }
            else {
                if repeatType == .one {
                    setSeek(seconds: 0)
                }
                else {
                    next(forwardEnableSong: true)
                }
            }
        }
        updateCurrentTime()
    }
    
    @objc func onInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        switch type {
        case .began:
            if isPlaying {
                pause()
            }
            break
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.play()
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc func onAudioSessionRouteChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
            return
        }
        
        switch reason {
        case .newDeviceAvailable:
            break
        case .oldDeviceUnavailable:
            if isPlaying {
                pause()
            }
        default:
            break
        }
    }
}
