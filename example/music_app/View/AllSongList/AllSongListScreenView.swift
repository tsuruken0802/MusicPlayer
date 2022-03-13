//
//  AllSongListScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import SwiftUI

struct AllSongListScreenView: View {
    let songs = MPMediaService.getAllSongs()
    
    var body: some View {
        VStack {
            MediaItemListView(items: songs, listType: .artwork, onTap: { _, index in
                withAnimation {
                    MusicPlayer.shared.play(items: songs, index: index)
                }
            })
        }
        .padding(.bottom, MiniPlayer.miniPlayerHeight)
    }
}

struct AllSongListScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AllSongListScreenView()
    }
}
