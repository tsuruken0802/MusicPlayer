//
//  MPSongItem.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/06.
//

import Foundation
import MediaPlayer

@available(iOS 13.0, *)
public class MPSongItemList {
    public let items: [MPSongItem]
    
    public init(items: [MPSongItem]) {
        self.items = items
    }
    
    public init() {
        self.items = []
    }
}

@available(iOS 13.0, *)
public class MPSongItem {
    public let item: MPMediaItem
    
    public let effect: MPSongItemEffect?
    
    public let trimming: MPSongItemTrimming?
    
    public var duration: TimeInterval { item.playbackDuration }
    
    public var id: MPMediaEntityPersistentID { item.persistentID }
    
    public var title: String? { item.title }
    
    public var artist: String? { item.artist }
    
    public var artwork: MPMediaItemArtwork? { item.artwork }
    
    public func image(size: CGFloat) -> UIImage? {
        return item.artwork?.image(at: CGSize(width: size, height: size))
    }
    
    public init(item: MPMediaItem, effect: MPSongItemEffect? = nil, trimming: MPSongItemTrimming? = nil) {
        self.item = item
        self.effect = effect
        self.trimming = trimming
    }
}

extension MPSongItem: Identifiable {}

@available(iOS 13.0, *)
public class MPSongItemEffect {
    public let rate: Float
    
    public let pitch: Float
    
    public init(rate: Float, pitch: Float) {
        self.rate = rate
        self.pitch = pitch
    }
}

@available(iOS 13.0, *)
public class MPSongItemTrimming {
    public let from: Float
    
    public let to: Float
    
    public var trimming: ClosedRange<Float> { from ... to }
    
    public init(from: Float, to: Float) {
        self.from = from
        self.to = to
    }
}
