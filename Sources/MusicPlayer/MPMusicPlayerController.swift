//
//  MPMusicPlayerController.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/09.
//

import Combine
import MediaPlayer

class MPMusicPlayerController: ObservableObject {
    @Published var currentItem: MPMediaItem?
    
    /// item duration
    public var duration: TimeInterval? {
        return currentItem?.playbackDuration
    }
    
    let musicPlayer = MPMusicPlayerApplicationController.applicationQueuePlayer
    
    public func play(item: MPMediaItem) {
        currentItem = item
        
        musicPlayer.setQueue(with: .init(items: [item]))
        
        musicPlayer.play()
    }
    
    public func pause() {
        musicPlayer.pause()
    }
    
    public func stop() {
        musicPlayer.stop()
    }
    
    public func seek(seconds: TimeInterval) {
        musicPlayer.currentPlaybackTime = seconds
    }
}
