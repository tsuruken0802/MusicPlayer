//
//  SongListViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import Foundation

class SongListViewModel: ObservableObject {
    @Published var items: [MPSongItem]
    
    init(items: [MPSongItem]) {
        self.items = items
    }
}
