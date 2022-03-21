//
//  MiniPlayerExpanedControllerView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import SwiftUI

struct MiniPlayerExpanedControllerView: View {
    @StateObject private var musicPlayer = MusicPlayer.shared
    
    // playback icon size
    private let playbackIconSize: CGFloat = 40
    
    private var playAndPauseImage: Image {
        return Image(systemName: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                musicPlayer.back()
            } label: {
                Image(systemName: "backward.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: playbackIconSize, height: playbackIconSize)
                    .foregroundColor(Color.primary)
                    .padding()
            }
            Spacer()
            Button {
                if musicPlayer.isPlaying {
                    musicPlayer.pause()
                }
                else {
                    musicPlayer.play()
                }
            } label: {
                playAndPauseImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: playbackIconSize, height: playbackIconSize)
                    .foregroundColor(Color.primary)
            }
            Spacer()
            Button {
                musicPlayer.next()
            } label: {
                Image(systemName: "forward.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: playbackIconSize, height: playbackIconSize)
                    .foregroundColor(Color.primary)
                    .padding()
            }
            Spacer()
        }
    }
}

struct MiniPlayerExpanedControllerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerExpanedControllerView()
    }
}
