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
    private let playbackIconSize: CGFloat = 35
    
    // seek seconds
    private let seekSeconds: Float = 5
    
    private var playAndPauseImage: some View {
        return image(name: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
    }
    
    private var spacer: some View {
        return Spacer(minLength: 0)
    }
    
    private func image(name: String) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .frame(width: playbackIconSize, height: playbackIconSize)
            .foregroundColor(Color.primary)
    }
    
    var body: some View {
        HStack {
            spacer
            
            Button {
                musicPlayer.setSeek(addingSeconds: -seekSeconds)
            } label: {
                image(name: "gobackward.\(Int(seekSeconds))")
            }
            
            spacer
            
            Group {
                Button {
                    musicPlayer.back()
                } label: {
                    image(name: "backward.fill")
                }
                
                spacer
                
                Button {
                    if musicPlayer.isPlaying {
                        musicPlayer.pause()
                    }
                    else {
                        musicPlayer.play()
                    }
                } label: {
                    playAndPauseImage
                }
                
                spacer
                
                Button {
                    musicPlayer.next()
                } label: {
                    image(name: "forward.fill")
                }
            }
            
            spacer
            
            Button {
                musicPlayer.setSeek(addingSeconds: seekSeconds)
            } label: {
                image(name: "goforward.\(Int(seekSeconds))")
            }
            
            spacer
        }
    }
}

struct MiniPlayerExpanedControllerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerExpanedControllerView()
    }
}
