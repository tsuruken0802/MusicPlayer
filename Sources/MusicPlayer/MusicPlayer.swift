import Combine
import Foundation
import AVFAudio
import MediaPlayer

@available(iOS 13.0, *)
final class MusicPlayer: ObservableObject {
    /// instance
    static let shared: MusicPlayer = .init()
    
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
    
    /// index of current playing MPMediaItem
    private var currentIndex: Int = 0 {
        didSet {
            // 曲が変われば秒数もリセットする
            cachedSeekBarSeconds = 0
            currentTime = 0
            
            setCurrentItem()
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    /// Threshold value whether return to the previous song
    /// value is seconds
    private static let backSameMusicThreshold: Float = 2.5
    
    /// If true, the current Time exceeds the song playback time
    private var isSeekOver: Bool {
        if let duration = duration {
            return currentTime >= Float(duration)
        }
        return false
    }
    
    /// item duration
    var duration: TimeInterval? {
        return currentItem?.playbackDuration
    }
    
    /// current playback item
    @Published private(set) var currentItem: MPMediaItem?
    
    /// true is player is playing
    @Published private(set) var isPlaying: Bool = false
    
    /// playback items
    @Published private var items: [MPMediaItem] = [] {
        didSet {
            setCurrentItem()
        }
    }
    
    private var currentTimeTimer: Timer?
    
    /// current playback time (seconed)
    @Published var currentTime: Float = 0
    
    /// Pitch
    @Published var pitch: Float = Constants.Pitch.defaultValue
    
    /// Rate
    @Published var rate: Float = Constants.Rate.defaultValue
    
    private init() {
        setAudioSession()
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
extension MusicPlayer {
    
    /// Play current item
    func play() {
        if isSeekOver || !isEnableAudio {
            return
        }
        do {
            try audioEngine.start()
            playerNode.play()
            isPlaying = true
            startCurrentTimeTimer()
            setNowPlayingInfo()
        }
        catch let e {
            print(e.localizedDescription)
        }
    }
    
    /// Play item
    /// - Parameters:
    ///   - items: playback items
    ///   - index: item index
    func play(items: [MPMediaItem], index: Int) {
        if !itemsSafe(items: items, index: index) {
            return
        }
        
        self.items = items
        self.currentIndex = index
        setScheduleFile()
        play()
    }
    
    /// Play next item
    func next() {
        let nextIndex = currentIndex + 1
        if !itemsSafe(index: nextIndex) {
            pause()
            return
        }
        currentIndex = nextIndex
        setScheduleFile()
        play()
    }
    
    /// Play previous item
    func back() {
        // 数秒しか経ってないなら同じ曲を0秒から再生する
        if currentTime >= MusicPlayer.backSameMusicThreshold {
            currentTime = 0
            setSeek(withPlay: isPlaying)
            return
        }
        
        let nextIndex = currentIndex - 1
        if !itemsSafe(index: nextIndex) {
            return
        }
        currentIndex = nextIndex
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
        stopCurrentTimeTimer()
    }
    
    /// set playback volume
    /// - Parameter value: volume
    func setVolume(value: Float) {
        playerNode.volume = value
    }
    
    /// change current playback position
    /// - Parameter withPlay: true if playback is performed after the position is changed
    func setSeek(withPlay: Bool = false) {
        let time = TimeInterval(currentTime)
        if time < 0 { return }
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
        
        if withPlay {
            play()
        }
        else {
            // 再生しない場合はnowPlayingInfoの値を更新しておく
            setNowPlayingInfo()
        }
    }
    
    /// increment playback pitch
    func incrementPitch() {
        if pitch >= Constants.Pitch.maxValue {
            return
        }
        pitch += Constants.Pitch.unit
    }
    
    /// decrement playback pitch
    func decrementPitch() {
        if pitch <= Constants.Pitch.minValue {
            return
        }
        pitch -= Constants.Pitch.unit
    }
    
    /// reset playback pitch
    func resetPitch() {
        pitch = Constants.Pitch.defaultValue
    }
    
    /// increment playback rate
    func incrementRate() {
        if rate >= Constants.Rate.maxValue {
            return
        }
        rate += Constants.Rate.unit
    }
    
    /// decrement playback rate
    func decrementRate() {
        if rate <= Constants.Rate.minValue {
            return
        }
        rate -= Constants.Rate.unit
    }
    
    /// reset playback rate
    func resetRate() {
        rate = Constants.Rate.defaultValue
    }
    
    /// set timer
    func startCurrentTimeTimer() {
        if currentTimeTimer?.isValid == true {
            return
        }
        currentTimeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.onUpdateCurrentTime), userInfo: nil, repeats: true)
    }
    
    /// stop timer
    func stopCurrentTimeTimer() {
        currentTimeTimer?.invalidate()
        currentTimeTimer = nil
    }
}

@available(iOS 13.0, *)
private extension MusicPlayer {
    /// update current playback time
    private func updateCurrentTime() {
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
    private func stop() {
        audioEngine.stop()
        playerNode.stop()
        isPlaying = false
    }
    
    /// check safe index
    /// - Parameters:
    ///   - items: playback list
    ///   - index: index
    /// - Returns: return true if index is safe
    private func itemsSafe(items: [MPMediaItem]? = nil, index: Int) -> Bool {
        let checkItems = items ?? self.items
        return checkItems.indices.contains(index)
    }
    
    /// set currentItem
    private func setCurrentItem() {
        if itemsSafe(index: currentIndex) {
            currentItem = items[currentIndex]
        }
    }
    
    /// set audio session
    private func setAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(.playback, mode: .default)
        try! session.setActive(true)
    }
    
    /// set notification
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onInterruption(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        NotificationCenter.default.addObserver(self, selector: #selector(onAudioSessionRouteChanged(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    /// set RemoteCommand
    private func setRemoteCommand() {
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
            setSeek(withPlay: isPlaying)
            return .success
        }
    }
    
    /// set nowPlayingInfo
    private func setNowPlayingInfo() {
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
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentItem?.playbackDuration
        
        // Set the metadata
        center.nowPlayingInfo = nowPlayingInfo
    }
    
    /// set Schedule File
    private func setScheduleFile() {
        guard let currentItem = currentItem else { return }
        do {
            audioFile = try AVAudioFile(forReading: currentItem.assetURL!)
            audioEngine.connect(playerNode, to: pitchControl, format: nil)
            audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: nil)
            playerNode.scheduleFile(audioFile!, at: nil)
        }
        catch let e {
            print(e.localizedDescription)
        }
    }
}

@available(iOS 13.0, *)
private extension MusicPlayer {
    
    /// current time timer handler
    @objc private func onUpdateCurrentTime() {
        if isSeekOver {
            next()
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
