//
//  MediaCollectionListViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import Foundation
import MediaPlayer

class MediaCollectionListViewModel: ObservableObject {
    @Published var mediaList: [MPSongItem] = []
    
    init(artistId: MPMediaEntityPersistentID) {
        let items = MPMediaService.getSongs(artistPersistentID: artistId)
        self.mediaList = items.map ({ MPSongItem(item: $0) })
    }
}

