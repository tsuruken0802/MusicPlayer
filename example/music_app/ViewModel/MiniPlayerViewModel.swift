//
//  MiniPlayerViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/22.
//

import Foundation
import Combine

class MiniPlayerViewModel: ObservableObject {
    @Published var currentItems: [MiniPlayerListItem] = []
    
    @Published var musicPlayer: MusicPlayer = MusicPlayer.shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    private static let maxListCount: Int = 20
    
    init() {
        musicPlayer.$items.sink { value in
            let index = min(value.count, MiniPlayerViewModel.maxListCount)
            if index <= 0 { return }
            let array = value[0...index]
            self.currentItems = array.map({ item in
                return MiniPlayerListItem.init(id: item.id, image: item.image(size: 50), title: item.title!, artist: item.artist)
            })
        }
        .store(in: &cancellables)
    }
}
