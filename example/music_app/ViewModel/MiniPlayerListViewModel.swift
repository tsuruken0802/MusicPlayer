//
//  MiniPlayerViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/22.
//

import Foundation
import Combine

class MiniPlayerListViewModel: ObservableObject {
    @Published var currentItems: [MiniPlayerListItem] = []
    
    @Published var musicPlayer: MusicPlayer = MusicPlayer.shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    private static let maxListCount: Int = 20
    
    init() {        
        musicPlayer.$currentIndex.sink { [weak self] value in
            guard let self = self else { return }
            let fromIndex = value + 1
            let toIndex = min(value+MiniPlayerListViewModel.maxListCount, self.musicPlayer.items.count-1)
            let indices = self.musicPlayer.items.indices
            if !indices.contains(fromIndex) || !indices.contains(toIndex) {
                self.currentItems.removeAll()
                return
            }
            let items = self.musicPlayer.items[fromIndex ... toIndex]
            self.currentItems = items.map({ item in
                return MiniPlayerListItem.init(id: item.id, image: item.image(size: 50), title: item.title!, artist: item.artist)
            })
        }
        .store(in: &cancellables)
    }
    
    func onMove(fromOffsets: IndexSet, toOffset: Int) {
        musicPlayer.moveItemPosition(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
