//
//  MPMediaItem+Extension.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import UIKit
import MediaPlayer

extension MPMediaItemCollection: Identifiable {
    public var id: UInt64 { self.persistentID }
}

extension MPMediaItemCollection {
    var playlistName: String? {
        return value(forProperty: MPMediaPlaylistPropertyName) as? String
    }
}

extension MPMediaItem: Identifiable {
    public var id: UInt64 { self.persistentID }
}

extension MPMediaItem {
    var year: Int? {
        return value(forProperty: "year") as? Int
    }
    
    func image(size: CGFloat) -> UIImage? {
        return artwork?.image(at: CGSize(width: size, height: size))
    }
}
