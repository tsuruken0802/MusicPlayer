import Combine
import Foundation
import AVFAudio
import MediaPlayer
import SwiftUI

@available(iOS 13.0, *)
public final class MusicPlayer: ObservableObject {
    /// instance
    public static let shared: MusicPlayer = .init()
    
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
    
    /// Current time timer schedule time
    private static let currentTimeTimerScheduleTime: Float = 0.5
    
    /// If true, the current Time exceeds the song playback time
    private var isSeekOver: Bool {
        return currentTime >= maxPlaybackTime
    }
    
    /// item duration
    public var duration: TimeInterval? {
        return currentItem?.duration
    }
    
    /// current playback item
    public var currentItem: MPSongItem? {
        if !items.indices.contains(currentIndex) {
            return nil
        }
        return items[currentIndex]
    }
    
    /// index of current playing MPMediaItem
    @Published private(set) public var currentIndex: Int = 0
    
    /// playback items
    @Published private(set) public var items: [MPSongItem] = []
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
    
    /// trimming(seconds)
    @Published public var playbackTimeRange: ClosedRange<Float>?
    private var minPlaybackTime: Float {
        return playbackTimeRange?.lowerBound ?? 0.0
    }
    private var maxPlaybackTime: Float {
        if let max = playbackTimeRange?.upperBound {
            return max
        }
        return Float(duration ?? 0.0)
    }
    
    /// shuffle
    @Published public var isShuffle: Bool = false
    
    /// repeat
    @Published public var repeatType: MPRepeatType = .none
    
    private init() {
        setNotification()
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchControl)
        setRemoteCommand()
        
        $pitch.sink { [weak self] value in
            guard let self = self else { return }
            self.pitchControl.pitch = MusicPlayerSerivce.enablePitchValue(value: value)
        }
        .store(in: &cancellables)
        
        $rate.sink { [weak self] value in
            guard let self = self else { return }
            self.pitchControl.rate = MusicPlayerSerivce.enableRateValue(value: value)
            self.startCurrentTimeRedering(currentRate: value)
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
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
        cancellables.forEach { (cancel) in
            cancel.cancel()
        }
    }
}

@available(iOS 13.0, *)
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
            startCurrentTimeRedering()
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
        setScheduleFile()
        play()
    }
    
    /// Play by id
    /// - Parameter id: item id
    func play(id: MPMediaEntityPersistentID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        if !itemsSafe(items: items, index: index) {
            return
        }
        currentIndex = index
        resetPlaybackTime()
        setScheduleFile()
        play()
    }
    
    /// Play next item
    func next() {
        var nextIndex = currentIndex + 1
        let isSafe = itemsSafe(index: nextIndex)
        switch repeatType {
        case .list:
            // restart
            if !isSafe {
                nextIndex = 0
            }
            // reshuffle
            if isShuffle {
                items = originalItems.shuffled()
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
        setScheduleFile()
        play()
    }
    
    /// Play previous item
    func back() {
        // 数秒しか経ってないなら同じ曲を0秒から再生する
        if currentTime >= MusicPlayer.backSameMusicThreshold {
            setSeek(seconds: minPlaybackTime)
            return
        }
        
        let nextIndex = currentIndex - 1
        if !itemsSafe(index: nextIndex) {
            return
        }
        currentIndex = nextIndex
        resetPlaybackTime()
        setScheduleFile()
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
    func startCurrentTimeRedering(currentRate: Float? = nil) {
        if currentTimeTimer?.isValid == true {
            stopCurrentTimeRendering()
        }
        let rate = currentRate ?? rate
        let valueRate = rate / MPConstants.defaultRateValue
        let value = MusicPlayer.currentTimeTimerScheduleTime / valueRate
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
}

@available(iOS 13.0, *)
private extension MusicPlayer {
    /// update current playback time
    func updateCurrentTime() {
        if let nodeTime = playerNode.lastRenderTime,
           let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
            let sampleRate = playerTime.sampleRate
            // シークバーを動かした後は内部的にsampleTimeが0にリセットされるため
            // 前回の再生時間を足す
            let newCurrentTime = Float(playerTime.sampleTime) / Float(sampleRate) + cachedSeekBarSeconds
            currentTime = min(newCurrentTime, Float(duration!))
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
        NotificationCenter.default.addObserver(self, selector: #selector(onInterruption(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        NotificationCenter.default.addObserver(self, selector: #selector(onAudioSessionRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    /// set RemoteCommand
    func setRemoteCommand() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            pause()
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            back()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            next()
            return .success
        }

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
    func setScheduleFile() {
        guard let currentItem = currentItem else { return }
        do {
            audioFile = try AVAudioFile(forReading: currentItem.item.assetURL!)
            audioEngine.connect(playerNode, to: pitchControl, format: nil)
            audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)
            playerNode.scheduleFile(audioFile!, at: nil)
        }
        catch let e {
            print(e.localizedDescription)
        }
    }
    
    /// shuffle items
    /// make currentItem the first element and shuffle the rest
    func shuffle() {
        guard let currentItemId = currentItem?.id else { return }
        var shuffled = items.shuffled()
        guard let currentItemIndex = shuffled.firstIndex(where: { $0.id == currentItemId }) else { return }
        shuffled.move(fromOffsets: [currentItemIndex], toOffset: 0)
        items = shuffled
        currentIndex = 0
        resetPlaybackTimeRange()
    }
    
    /// set original sort
    func setOriginalSort() {
        guard let originalIndex = originalItems.firstIndex(where: { $0.id == currentItem?.id }) else { return }
        items = originalItems
        currentIndex = originalIndex
        resetPlaybackTimeRange()
    }
    
    /// reset playback time
    func resetPlaybackTime() {
        cachedSeekBarSeconds = 0
        currentTime = 0
        resetPlaybackTimeRange()
    }
    
    /// reset playback time range
    func resetPlaybackTimeRange() {
        playbackTimeRange = 0.0...Float(duration ?? 0.0)
    }
}

@available(iOS 13.0, *)
private extension MusicPlayer {
    
    /// current time timer handler
    @objc private func onUpdateCurrentTime() {
        if isSeekOver {
            if repeatType == .one {
                setSeek(seconds: 0)
            }
            else {
                next()
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
}
