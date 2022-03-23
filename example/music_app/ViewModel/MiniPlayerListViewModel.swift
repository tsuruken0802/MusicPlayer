//
//  MiniPlayerViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/22.
//

import Foundation
import Combine
import SwiftUI

class MiniPlayerListViewModel: ObservableObject {
    @Published var currentItems: [MiniPlayerListItem] = []
    
    @Published var musicPlayer: MusicPlayer = MusicPlayer.shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    private static let maxListCount: Int = 20
    
    init() {
        musicPlayer.$currentIndex.sink { [weak self] value in
            guard let self = self else { return }
            self.updateCurrentItems(currentItemIndex: value)
        }
        .store(in: &cancellables)
    }
}

extension MiniPlayerListViewModel {
    func onMove(fromOffsets: IndexSet, toOffset: Int) {
        musicPlayer.moveItemPosition(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}

private extension MiniPlayerListViewModel {
    /// update current items
    /// - Parameter currentItemIndex: current item index
    func updateCurrentItems(currentItemIndex: Int) {
        let fromIndex = currentItemIndex + 1
        let toIndex = min(currentItemIndex+MiniPlayerListViewModel.maxListCount, self.musicPlayer.items.count-1)
        let indices = self.musicPlayer.items.indices
        if !indices.contains(fromIndex) || !indices.contains(toIndex) {
            self.currentItems.removeAll()
            return
        }
        let items = self.musicPlayer.items[fromIndex ... toIndex]
        withAnimation {
            self.currentItems = items.map({ item in
                return MiniPlayerListItem.init(id: item.id, image: item.image(size: 50), title: item.title!, artist: item.artist)
            })
        }
    }
}
