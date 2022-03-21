//
//  SongItem.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import Foundation
import UIKit
import MediaPlayer

class SongItem {
    let id: MPMediaEntityPersistentID
    
    let image: UIImage
    
    let title: String
    
    let artist: String?
    
    init(id: MPMediaEntityPersistentID,
         image: UIImage,
         title: String,
         artist: String) {
        self.id = id
        self.image = image
        self.title = title
        self.artist = artist
    }
}
