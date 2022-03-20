//
//  MusicPlaybackSliderView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import SwiftUI

struct MusicPlaybackSliderView: View {
    @ObservedObject private var musicPlayer = MusicPlayer.shared
    
    var isEditingSlideBar: Binding<Bool>?
    
    var body: some View {
        VStack {
            if let duration = musicPlayer.duration, duration > 0.0 {
                Slider(value: $musicPlayer.currentTime, in: 0.0...Float(duration), step: 0.1) { isEditing in
                    isEditingSlideBar?.wrappedValue = isEditing
                    if isEditing {
                        musicPlayer.stopCurrentTimeRendering()
                    }
                    else {
                        musicPlayer.startCurrentTimeRedering()
                        musicPlayer.setSeek(withPlay: musicPlayer.isPlaying)
                    }
                }
                
                HStack {
                    Text(PlayBackTimeConverter.toString(seconds: musicPlayer.currentTime))
                    Spacer()
                    Text(PlayBackTimeConverter.toString(seconds: Float(duration)))
                }
            }
        }
    }
}

struct MusicPlaybackSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlaybackSliderView()
    }
}
