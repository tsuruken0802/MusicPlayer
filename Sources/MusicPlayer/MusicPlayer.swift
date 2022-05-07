import Combine
import Foundation
import AVFAudio
import MediaPlayer
import SwiftUI

public final class MusicPlayer: ObservableObject {
    /// instance
    public static let shared: MusicPlayer = .init()
    
    private var backgroundMode: Bool = false
    
    /// Engine and Nodes
    private let audioEngine: AVAudioEngine = .init()
    private let playerNode: AVAudioPlayerNode = .init()
    private let pitchControl: AVAudioUnitTimePitch = .init()
    private var audioFile: AVAudioFile?
    
    /// Cache of playback time when moving the seek bar
    private var cachedSeekBarSeconds: Float = 0
    
    /// return true if playable
    private var isEnableAudio: Bool {
        return audioFile != nil
    }
    
    private var currentTimeTimer: Timer?
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Threshold value whether return to the previous song
    /// value is seconds
    private static let backSameMusicThreshold: Float = 2.5
    
    /// index of current playing MPMediaItem
    private var currentIndex: Int {
        get { itemList.currentIndex }
        set { itemList.currentIndex = newValue }
    }
    
    /// If true, the current Time exceeds the song playback time
    private var isSeekOver: Bool {
        return currentTime >= maxPlaybackTime
    }
    
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
    public var currentTimeTimerScheduleTime: Float = 0.5 {
        didSet {
            stopCurrentTimeRendering()
            startCurrentTimeRendering()
        }
    }
    
    /// playback items
    @Published private(set) public var itemList: MPSongItemList = .init()
    private(set) public var items: [MPSongItem] {
        get { return itemList.items }
        set { itemList = .init(items: newValue, currentIndex: currentIndex) }
    }
    private var originalItems: [MPSongItem] = []
    
    /// true is player is playing
    @Published private(set) public var isPlaying: Bool = false
    
    /// current playback time (seconds)
    @Published public var currentTime: Float = 0
    
    /// Pitch
    @Published public var pitch: Float = MPConstants.defaultPitchValue
    @Published public var pitchOptions: MusicEffectRangeOption = .init(minValue: MPConstants.defaultPitchMinValue,
                                                                       maxValue: MPConstants.defaultPitchMaxValue,
                                                                       unit: MPConstants.defaultPitchUnit,
                                                                       defaultValue: MPConstants.defaultPitchValue)
    
    /// Rate
    @Published public var rate: Float = MPConstants.defaultRateValue
    @Published public var rateOptions: MusicEffectRangeOption = .init(minValue: MPConstants.defaultRateMinValue,
                                                                      maxValue: MPConstants.defaultRateMaxValue,
                                                                      unit: MPConstants.defaultRateUnit,
                                                                      defaultValue: MPConstants.defaultRateValue)
    
    /// trimming(seconds) and divisions
    @Published public var playbackTimeRange: ClosedRange<Float>? {
        didSet {
            if playbackTimeRange != nil {
                division.clear()
            }
        }
    }
    
    @Published public var division: MPDivision = .init() {
        didSet {
            if !division.isEmpty {
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
    
    private var minPlaybackTime: Float {
        if let playbackTimeRange = playbackTimeRange {
            return playbackTimeRange.lowerBound
        }
        else if let from = division.from(currentTime: currentTime) {
            return from
        }
        return 0.0
    }
    
    private var minThresholdTime: Float {
        if let playbackTimeRange = playbackTimeRange {
            return playbackTimeRange.lowerBound + MusicPlayer.backSameMusicThreshold
        }
        else if let from = division.from(currentTime: currentTime, threshold: MusicPlayer.backSameMusicThreshold) {
            return from
        }
        return 0.0
    }
    
    private var maxPlaybackTime: Float {
        if let max = playbackTimeRange?.upperBound {
            return max
        }
        let duration = fDuration
        if let max = division.to(currentTime: currentTime, duration: duration) {
            return max
        }
        return duration
    }
    
    /// shuffle
    @Published public var isShuffle: Bool = false
    
    /// repeat
    @Published public var repeatType: MPRepeatType = .none
    
    /// remote command
    @Published public var rightRemoteCommand: MPRemoteCommandType = .nextTrack
    @Published public var leftRemoteCommand: MPRemoteCommandType = .previousTrack
    
    /// skip seconds on remote command
    @Published public var remoteSkipSeconds: Int = 5
    
    private init() {
        setNotification()
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchControl)
        initRemoteCommand()
        
        $pitch.sink { [weak self] value in
            guard let self = self else { return }
            self.pitchControl.pitch = MusicPlayerSerivce.enablePitchValue(value: value)
        }
        .store(in: &cancellables)
        
        $rate.sink { [weak self] value in
            guard let self = self else { return }
            self.pitchControl.rate = MusicPlayerSerivce.enableRateValue(value: value)
            self.startCurrentTimeRendering(currentRate: value)
        }
        .store(in: &cancellables)
        
        $playbackTimeRange.sink { [weak self] value in
            guard let self = self else { return }
            guard let value = value else { return }
            let minPlaybackTime = value.lowerBound
            let maxPlaybackTime = value.upperBound
            if self.currentTime < minPlaybackTime {
                self.currentTime = minPlaybackTime
                self.setSeek()
            }
            else if self.currentTime > maxPlaybackTime {
                self.currentTime = maxPlaybackTime
                self.setSeek()
            }
        }
        .store(in: &cancellables)
        
        $isShuffle.sink { [weak self] value in
            guard let self = self else { return }
            if value {
                self.shuffle()
            }
            else {
                self.setOriginalSort()
            }
        }
        .store(in: &cancellables)
        
        $rightRemoteCommand.sink { [weak self] value in
            guard let self = self else { return }
            self.setLeftAndRightRemoteCommandValue(rightCommand: value)
        }
        .store(in: &cancellables)
        
        $leftRemoteCommand.sink { [weak self] value in
            guard let self = self else { return }
            self.setLeftAndRightRemoteCommandValue(leftCommand: value)
        }
        .store(in: &cancellables)
        
        $remoteSkipSeconds.sink { [weak self] value in
            guard let self = self else { return }
            self.setLeftAndRightRemoteCommandValue(skipSeconds: value)
        }
        .store(in: &cancellables)
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
        cancellables.forEach { (cancel) in
            cancel.cancel()
        }
    }
}

public extension MusicPlayer {
    /// Play current item
    func play() {
        if isSeekOver || !isEnableAudio {
            return
        }
        
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
        self.originalItems = items
        self.items = items
        self.currentIndex = index
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
    
    /// Play next item
    /// forwardEnableSong: if true, advance index to valid song
    func next(forwardEnableSong: Bool = false) {
        // if there is a Division, move to that number of seconds
        if let nextDivision = division.to(currentTime: currentTime, duration: fDuration) {
            if nextDivision < fDuration {
                setSeek(seconds: nextDivision)
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
    func back(backEnableSong: Bool = false) {
        let minThresholdTime = minThresholdTime
        if minThresholdTime <= currentTime {
            if trimmingType == .trimming {
                setSeek(seconds: minPlaybackTime)
            }
            else {
                setSeek(seconds: minThresholdTime)
            }
            return
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
    
    /// set playback volume
    /// - Parameter value: volume
    func setVolume(value: Float) {
        playerNode.volume = value
    }
    
    /// change current playback position
    /// - Parameter withPlay: true if playback is performed after the position is changed
    func setSeek(withPlay: Bool? = nil) {
        // range外の再生時間でseekしようとした場合はrange内に収めてから行うようにする
        if let playbackTimeRange = self.playbackTimeRange {
            if !playbackTimeRange.contains(currentTime) {
                currentTime = min(max(minPlaybackTime, currentTime), maxPlaybackTime)
            }
        }
        let time = TimeInterval(currentTime)
        let isPlay = withPlay ?? isPlaying
        guard let duration = duration else { return }
        guard let audioFile = audioFile else { return }
        if time > duration { return }
        
        let sampleRate = audioFile.processingFormat.sampleRate
        let startFrame = AVAudioFramePosition(sampleRate * time)
        if (startFrame < 0) { return }
        
        var length = duration - time
        if length <= 0 { length = 0 }
        var frameCount = AVAudioFrameCount(length * Double(sampleRate))
        if frameCount <= 0 { frameCount = 1 }   // 0だとクラッシュするので極小値で対応

        cachedSeekBarSeconds = Float(time)
        
        stop()
    
        playerNode.scheduleSegment(audioFile, startingFrame: startFrame, frameCount: frameCount, at: nil)
    
        if isPlay {
            play()
        }
        else {
            // 再生しない場合はnowPlayingInfoの値を更新しておく
            setNowPlayingInfo()
        }
    }
    
    /// change current playback position
    /// - Parameters:
    ///   - seconds: move seconds time
    ///   - withPlay: with play
    func setSeek(seconds: Float, withPlay: Bool? = nil) {
        currentTime = seconds
        setSeek(withPlay: withPlay)
    }
    
    /// change current playback position
    /// - Parameters:
    ///   - addingSeconds: adding seconds time
    ///   - withPlay: with play
    func setSeek(addingSeconds: Float, withPlay: Bool? = nil) {
        currentTime += addingSeconds
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
        if currentTimeTimer?.isValid == true {
            stopCurrentTimeRendering()
        }
        let rate = currentRate ?? rate
        let valueRate = rate / MPConstants.defaultRateValue
        let value = currentTimeTimerScheduleTime / valueRate
        currentTimeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(value), target: self, selector: #selector(self.onUpdateCurrentTime), userInfo: nil, repeats: true)
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
    func updateSongEffect(songId: UInt64,
                          effect: MPSongItemEffect?,
                          trimming: ClosedRange<Float>?,
                          divisions: [Float]?) {
        updateSongEffect(songs: items, songId: songId, effect: effect, trimming: trimming, divisions: divisions)
        updateSongEffect(songs: originalItems, songId: songId, effect: effect, trimming: trimming, divisions: divisions)
        let isCurrentItem = songId == currentItem?.id
        if isCurrentItem {
            rate = effect?.rate ?? rate
            pitch = effect?.pitch ?? pitch
            playbackTimeRange = trimming
            if let divisions = divisions {
                division = .init(values: divisions)
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
        }
        if let trimming = trimming {
            playbackTimeRange = trimming.trimming
        }
        if let division = division {
            self.division = division
        }
    }
    
    /// reset song effects
    func resetCurrentEffects() {
        resetRate()
        resetPitch()
        playbackTimeRange = nil
    }
    
    /// reset effects by song id
    /// - Parameter songId: song id
    func resetEffects(songId: UInt64) {
        guard let index = items.firstIndex(where: { $0.id == songId }) else { return }
        items[index].effect = .init(rate: rateOptions.defaultValue, pitch: pitchOptions.defaultValue)
        items[index].trimming = nil
    }
}

private extension MusicPlayer {
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
    
    /// update song effect
    /// - Parameters:
    ///   - songs: songs
    ///   - songId: song id
    ///   - effect: effect
    ///   - trimming: trimming
    ///   - divisions: divisions
    func updateSongEffect(songs: [MPSongItem],
                          songId: UInt64,
                          effect: MPSongItemEffect?,
                          trimming: ClosedRange<Float>?,
                          divisions: [Float]?) {
        guard let song = songs.first(where: { $0.id == songId }) else { return }
        if let effect = effect {
            song.effect = .init(rate: effect.rate, pitch: effect.pitch)
        }
        if let trimming = trimming {
            song.trimming = .init(trimming: trimming)
        }
        if let divisions = divisions {
            song.division = .init(values: divisions)
        }
    }
    
    /// update current playback time
    func updateCurrentTime() {
        if let nodeTime = playerNode.lastRenderTime,
           let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            let sampleRate = playerTime.sampleRate
            // シークバーを動かした後は内部的にsampleTimeが0にリセットされるため
            // 前回の再生時間を足す
            let newCurrentTime = Float(playerTime.sampleTime) / Float(sampleRate) + cachedSeekBarSeconds
            currentTime = min(newCurrentTime, fDuration)
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterForeground),
                                               name: UIApplication.didBecomeActiveNotification,
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
        let leftCommand: MPRemoteCommandType = self.leftRemoteCommand
        let rightCommand: MPRemoteCommandType = self.rightRemoteCommand
        let skipSeconds: Int = self.remoteSkipSeconds
        
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
        commandCenter.previousTrackCommand.isEnabled = !leftCommand.isSkipType
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            back(backEnableSong: self.backgroundMode)
            return .success
        }
        
        commandCenter.nextTrackCommand.removeTarget(self)
        commandCenter.nextTrackCommand.isEnabled = !rightCommand.isSkipType
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            next(forwardEnableSong: self.backgroundMode)
            return .success
        }
        
        commandCenter.skipForwardCommand.removeTarget(self)
        commandCenter.skipForwardCommand.isEnabled = rightCommand.isSkipType
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(integerLiteral: skipSeconds)]
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            setSeek(addingSeconds: Float(remoteSkipSeconds))
            return .success
        }
        
        commandCenter.skipBackwardCommand.removeTarget(self)
        commandCenter.skipBackwardCommand.isEnabled = leftCommand.isSkipType
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(integerLiteral: skipSeconds)]
        commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
            setSeek(addingSeconds: Float(-remoteSkipSeconds))
            return .success
        }

        commandCenter.changePlaybackPositionCommand.removeTarget(self)
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            guard let positionCommandEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            currentTime = Float(positionCommandEvent.positionTime)
            setSeek()
            return .success
        }
    }
    
    /// set nowPlayingInfo
    func setNowPlayingInfo() {
        let center =  MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = center.nowPlayingInfo ?? [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentItem?.title
        
        let size = CGSize(width: 50, height: 50)
        if let image = currentItem?.artwork?.image(at: size) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
        }
        else {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = nil
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime

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
    func setScheduleFile() -> Bool {
        audioFile = nil
        guard let assetURL = currentItem?.item.assetURL else { return false }
        do {
            audioFile = try AVAudioFile(forReading: assetURL)
            audioEngine.connect(playerNode, to: pitchControl, format: nil)
            audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)
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
        cachedSeekBarSeconds = 0
        currentTime = 0
        playbackTimeRange = 0.0...fDuration
    }
}

private extension MusicPlayer {
    
    /// current time timer handler
    @objc private func onUpdateCurrentTime() {
        if isSeekOver {
            if repeatType == .one {
                setSeek(seconds: 0)
            }
            else {
                next(forwardEnableSong: true)
            }
            return
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
            guard let optionsValue =
                userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
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
            if !isPlaying {
                play()
            }
        case .oldDeviceUnavailable:
            if isPlaying {
                pause()
            }
        default:
            break
        }
    }
    
    @objc func didEnterBackground() {
        backgroundMode = true
    }
    
    @objc func didEnterForeground() {
        backgroundMode = false
    }
}
