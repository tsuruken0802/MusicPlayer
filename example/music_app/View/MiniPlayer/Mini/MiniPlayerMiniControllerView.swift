//
//  MiniPlayerControllerView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import SwiftUI

struct MiniPlayerMiniControllerView: View {
    @StateObject private var musicPlayer = MusicPlayer.shared
    
    private var playAndPauseImage: Image {
        return Image(systemName: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
    }
    
    var body: some View {
        Group {
            Button {
                if musicPlayer.isPlaying {
                    musicPlayer.pause()
                }
                else {
                    musicPlayer.play()
                }
            } label: {
                playAndPauseImage
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(6)
            }
            
            Button {
                musicPlayer.next()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(6)
            }
        }
    }
}

struct MiniPlayerControllerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerMiniControllerView()
    }
}
