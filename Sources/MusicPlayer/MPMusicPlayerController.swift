//
//  MPMusicPlayerController.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/09.
//

import Combine
import MediaPlayer

class MPMusicPlayerController: ObservableObject {
    
    private let musicPlayer: MPMusicPlayerApplicationController = .applicationQueuePlayer
    
    private var currentItem: MPMediaItem?
    
    /// item duration
    public var duration: TimeInterval? {
        return currentItem?.playbackDuration
    }
    
    public var currentTime: TimeInterval {
        return musicPlayer.currentPlaybackTime
    }
}

extension MPMusicPlayerController {
    func play(item: MPMediaItem) {
        currentItem = item
        
        musicPlayer.setQueue(with: .init(items: [item]))
        
        musicPlayer.play()
    }
    
    func pause() {
        musicPlayer.pause()
    }
    
    func stop() {
        musicPlayer.stop()
    }
    
    func seek(seconds: TimeInterval) {
        musicPlayer.currentPlaybackTime = seconds
    }
}
