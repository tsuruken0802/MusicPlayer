//
//  MiniPlayerViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/22.
//

import Foundation
import Observation
import SwiftUI

class MiniPlayerListViewModel: ObservableObject {
    @Published var currentItems: [MiniPlayerListItem] = []
    
    @Published var musicPlayer: MusicPlayer = MusicPlayer.shared
    
    private static let maxListCount: Int = 20
    
    init() {
        _ = withObservationTracking {
            musicPlayer.itemList
        } onChange: { [weak self] in
            guard let self = self else { return }
            self.updateCurrentItems(songs: self.musicPlayer.itemList.items, currentItemIndex: self.musicPlayer.itemList.currentIndex)
        }
    }
}

extension MiniPlayerListViewModel {
    func onMove(fromOffsets: IndexSet, toOffset: Int) {
        musicPlayer.moveItem(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    func onTapItem(item: MiniPlayerListItem) {
        musicPlayer.play(id: item.id)
    }
}

private extension MiniPlayerListViewModel {
    /// update current items
    /// - Parameter songs: songs
    /// - Parameter currentItemIndex: current item index
    func updateCurrentItems(songs: [MPSongItem], currentItemIndex: Int) {
        let fromIndex = currentItemIndex + 1
        let toIndex = min(currentItemIndex+MiniPlayerListViewModel.maxListCount, songs.count-1)
        let indices = songs.indices
        if !indices.contains(fromIndex) || !indices.contains(toIndex) {
            currentItems.removeAll()
            return
        }
        let items = songs[fromIndex ... toIndex]
        currentItems = items.map({ item in
            return MiniPlayerListItem.init(id: item.id, image: item.item.image(size: 50), title: item.displayTitle!, artist: item.item.artist)
        })
    }
}
