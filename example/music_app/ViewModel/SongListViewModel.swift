//
//  SongListViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import Foundation
import MediaPlayer

class SongListViewModel: ObservableObject {
    @Published var items: [MPMediaItem]
    
    init(items: [MPMediaItem]) {
        self.items = items
    }
}
