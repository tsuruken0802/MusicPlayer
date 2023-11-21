//
//  MiniPlayerShowListSongNameView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/22.
//

import SwiftUI

struct MiniPlayerShowListSongNameView: View {
    @State private var musicPlayer = MusicPlayer.shared
    
    private var songName: String {
        return musicPlayer.currentItem?.displayTitle ?? "再生停止中"
    }
    
    private var artistName: String {
        return musicPlayer.currentItem?.item.artist ?? ""
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(songName)
                .lineLimit(1)
            
            Text(artistName)
                .lineLimit(1)
        }
    }
}

struct MiniPlayerShowListSongNameView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerShowListSongNameView()
    }
}
