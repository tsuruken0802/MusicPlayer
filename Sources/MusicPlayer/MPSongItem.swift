//
//  MPSongItem.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/06.
//

import Foundation
import MediaPlayer

// struct OK?
public struct MPSongItemList {
    public let items: [MPSongItem]
    public var currentIndex: Int
    public var currentItem: MPSongItem? {
        if !items.indices.contains(currentIndex) {
            return nil
        }
        return items[currentIndex]
    }
    
    public init(items: [MPSongItem], currentIndex: Int = 0) {
        self.items = items
        self.currentIndex = currentIndex
    }
    
    public init() {
        self.items = []
        self.currentIndex = 0
    }
}

public class MPSongItem {
    public let item: MPMediaItem
    public var effect: MPSongItemEffect?
    public var trimming: MPSongItemTrimming?
    public var division: MPDivision?
    public var duration: TimeInterval { item.playbackDuration }
    public var id: MPMediaEntityPersistentID { item.persistentID }
    public var title: String?
    public var lyrics: String?
    public var artist: String? { item.artist }
    public var artwork: MPMediaItemArtwork? { item.artwork }
    
    public func image(size: CGFloat) -> UIImage? {
        return item.artwork?.image(at: CGSize(width: size, height: size))
    }
    
    public init(item: MPMediaItem,
                effect: MPSongItemEffect? = nil,
                trimming: MPSongItemTrimming? = nil,
                divisions: MPDivision? = nil,
                title: String? = nil,
                lyrics: String? = nil) {
        self.item = item
        self.effect = effect
        self.trimming = trimming
        self.division = divisions
        self.title = title
        self.lyrics = lyrics
    }
}

public extension MPSongItem {
    var displayTitle: String? {
        return title ?? item.title
    }
}

extension MPSongItem: Identifiable {}

public struct MPSongItemEffect {
    public let rate: Float
    public let pitch: Float
    public let reverb: MPSongReverbEffect?
    
    public init(rate: Float, pitch: Float, reverb: MPSongReverbEffect?) {
        self.rate = rate
        self.pitch = pitch
        self.reverb = reverb
    }
}

public struct MPSongItemTrimming {
    public let trimming: ClosedRange<Float>
    
    public init(trimming: ClosedRange<Float>) {
        self.trimming = trimming
    }
}

public struct MPSongReverbEffect {
    // 0 ... 100
    public let value: Float
    
    // if null, reverb is nothing
    public let type: AVAudioUnitReverbPreset?
    
    public init(value: Float, type: AVAudioUnitReverbPreset?) {
        self.value = value
        self.type = type
    }
}
