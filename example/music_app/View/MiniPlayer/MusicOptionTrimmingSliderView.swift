//
//  MusicOptionTrimmingSliderView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import SwiftUI
import RangeSlider

struct MusicOptionTrimmingSliderView: View {
    @ObservedObject private var musicPlayer = MusicPlayer.shared
    
    @ObservedObject private var viewModel: MusicOptionTrimmingSliderViewModel = .init()
    
    var body: some View {
        VStack {
            if let duration = musicPlayer.duration, duration > 0.0 {
                RangeSlider(currentValue: $viewModel.currentValue,
                            bounds: 0.0...Float(duration),
                            tintColor: Color.green) { isEditing in
                    if !isEditing {
                        musicPlayer.playbackTimeRange = viewModel.currentValue
                    }
                }
                
                HStack {
                    Text(PlayBackTimeConverter.toString(seconds: Float(viewModel.currentValue.lowerBound)))
                    Spacer()
                    Text(PlayBackTimeConverter.toString(seconds: Float(viewModel.currentValue.upperBound)))
                }
            }
        }
    }
}

//struct MusicOptionTrimmingSliderView_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicOptionTrimmingSliderView()
//    }
//}
