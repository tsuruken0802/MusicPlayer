//
//  ArtistListViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/03.
//

import Foundation
import MediaPlayer

class ArtistListViewModel: ObservableObject {
    @Published var artists: [MPMediaItem] = []
    
    init() {
        let artistQuery = MPMediaQuery.artists()
        self.artists = artistQuery.collections?.compactMap({ collection in
            return collection.representativeItem
        }) ?? []
    }
}
