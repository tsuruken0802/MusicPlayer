//
//  MusicPlaybackSliderView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import SwiftUI

struct MusicPlaybackSliderView: View {
    @StateObject private var musicPlayer = MusicPlayer.shared
    
    var showTrimmingPosition: Bool?
    
    private var duration: TimeInterval? {
        guard let duration = musicPlayer.duration else { return nil }
        return duration > 0.0 ? duration : nil
    }
    
    private var trimmingLowerRate: Float? {
        guard let lower = musicPlayer.playbackTimeRange?.lowerBound else { return nil }
        guard let duration = duration else { return nil }
        if lower <= 0.0 { return nil }
        return lower / Float(duration)
    }
    
    private var trimmingUpperRate: Float? {
        guard let upper = musicPlayer.playbackTimeRange?.upperBound else { return nil }
        guard let duration = duration else { return nil }
        let fDuration = Float(duration)
        if upper >= fDuration { return nil }
        return upper / fDuration
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let duration = musicPlayer.duration, duration > 0.0 {
                Slider(value: $musicPlayer.currentTime, in: 0.0...Float(duration), step: 0.1) { isEditing in
                    if isEditing {
                        musicPlayer.stopCurrentTimeRendering()
                    }
                    else {
                        musicPlayer.startCurrentTimeRedering()
                        musicPlayer.setSeek(withPlay: musicPlayer.isPlaying)
                    }
                }
                
                if trimmingLowerRate != nil || trimmingUpperRate != nil {
                    if showTrimmingPosition == true {
                        // Sliderと幅を揃えたいがSliderの内部で
                        // 微量のPaddingを含んでいるため微調整する
                        MiniPlayerTrimmingPositionView(lowerRate: trimmingLowerRate, upperRate: trimmingUpperRate)
                            .padding(.horizontal, 1)
                            .padding(.vertical, 10)
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
