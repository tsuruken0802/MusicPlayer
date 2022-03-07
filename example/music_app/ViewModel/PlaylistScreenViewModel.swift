//
//  PlaylistScreenViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import Foundation
import MediaPlayer

class PlaylistScreenViewModel: ObservableObject {
    @Published var playlists: [MPMediaItemCollection] = []
    
    init() {
        let myPlaylistQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistQuery.collections
        self.playlists = playlists ?? []
    }
}

