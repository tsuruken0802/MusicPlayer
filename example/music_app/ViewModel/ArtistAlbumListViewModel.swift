//
//  ArtistAlbumListViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/03.
//

import Foundation
import MediaPlayer

class ArtistAlbumListViewModel: ObservableObject {
    @Published var albums: [MPMediaItem] = []
    
    init(artistId: MPMediaEntityPersistentID) {
        self.albums = MPMediaService.getAlbums(artistPersistentID: artistId)
    }
}
