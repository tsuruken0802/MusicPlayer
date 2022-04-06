//
//  MPSongItem.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/06.
//

import Foundation
import MediaPlayer

@available(iOS 13.0, *)
public class MPSongItem {
    public let item: MPMediaItem
    
    public let effect: MPSongItemEffect?
    
    public let trimming: ClosedRange<Float>?
    
    public var duration: TimeInterval { item.playbackDuration }
    
    public var id: MPMediaEntityPersistentID { item.persistentID }
    
    public var title: String? { item.title }
    
    public var artwork: MPMediaItemArtwork? { item.artwork }
    
    init(item: MPMediaItem, effect: MPSongItemEffect? = nil, trimming: ClosedRange<Float>? = nil) {
        self.item = item
        self.effect = effect
        self.trimming = trimming
    }
}

@available(iOS 13.0, *)
public class MPSongItemEffect {
    public let rate: Float
    
    public let pitch: Float
    
    init(rate: Float, pitch: Float) {
        self.rate = rate
        self.pitch = pitch
    }
}
