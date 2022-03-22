//
//  MiniPlayerMiniContentView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/22.
//

import SwiftUI

struct MiniPlayerMiniContentView: View {
    
    @StateObject private var musicPlayer = MusicPlayer.shared
    
    private var songName: String {
        return musicPlayer.currentItem?.title ?? "再生停止中"
    }
    
    private var artistName: String {
        return musicPlayer.currentItem?.artist ?? ""
    }
    
    var body: some View {
        HStack {
            Text(songName)
                .lineLimit(1)
                .font(.body)
            
            Spacer()
            
            MiniPlayerMiniControllerView()
        }
    }
}

struct MiniPlayerMiniContentView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerMiniContentView()
    }
}
