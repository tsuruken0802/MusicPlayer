//
//  SongListScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI
import MediaPlayer

struct SongListScreenView: View {
    @StateObject var viewModel: SongListViewModel
    
    init(items: [MPSongItem]) {
        _viewModel = StateObject(wrappedValue: SongListViewModel(items: items))
    }
    
    var body: some View {
        VStack {
            MediaItemListView(items: viewModel.items, listType: .number, onTap: { _, index in
                withAnimation {
                    MusicPlayer.shared.play(items: viewModel.items, index: index)
                }
            })
        }
        .padding(.bottom, MiniPlayer.miniPlayerHeight)
    }
}

struct SongListScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SongListScreenView(items: [])
    }
}
