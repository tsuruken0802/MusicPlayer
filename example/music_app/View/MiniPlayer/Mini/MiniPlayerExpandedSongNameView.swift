//
//  MiniPlayerExpandedSongNameView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/22.
//

import SwiftUI

struct MiniPlayerExpandedSongNameView: View {
    @StateObject private var musicPlayer = MusicPlayer.shared
    
    private var songName: String {
        return musicPlayer.currentItem?.title ?? "再生停止中"
    }
    
    private var artistName: String {
        return musicPlayer.currentItem?.artist ?? ""
    }
    
    var body: some View {
        VStack {
            Text(songName)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
                .padding(.bottom, 10)
            
            Text(artistName)
                .lineLimit(1)
                .font(.title2)
        }
    }
}

struct MiniPlayerExpandedSongNameView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerExpandedSongNameView()
    }
}
