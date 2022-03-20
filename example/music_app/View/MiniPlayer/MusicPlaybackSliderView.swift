//
//  MusicPlaybackSliderView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import SwiftUI

struct MusicPlaybackSliderView: View {
    @ObservedObject var musicPlayer = MusicPlayer.shared
    
    var isEditingSlideBar: Binding<Bool>?
    
    var body: some View {
        VStack {
            if musicPlayer.maxPlaybackTime > 0.0 {
                Slider(value: $musicPlayer.currentTime, in: musicPlayer.minPlaybackTime...Float(musicPlayer.maxPlaybackTime), step: 0.1) { isEditing in
                    isEditingSlideBar?.wrappedValue = isEditing
                    if isEditing {
                        musicPlayer.stopCurrentTimeRendering()
                    }
                    else {
                        musicPlayer.startCurrentTimeRedering()
                        musicPlayer.setSeek(withPlay: musicPlayer.isPlaying)
                    }
                }
            }
            
            HStack {
                Text(PlayBackTimeConverter.toString(seconds: musicPlayer.currentTime))
                Spacer()
                Text(PlayBackTimeConverter.toString(seconds: Float(musicPlayer.maxPlaybackTime)))
            }
        }
    }
}

struct MusicPlaybackSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlaybackSliderView()
    }
}
