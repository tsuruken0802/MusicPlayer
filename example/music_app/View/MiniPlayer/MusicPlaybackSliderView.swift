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
    
    var duration: Float {
        return musicPlayer.fDuration
    }
    
    private var trimmingPositionRates: [Float] {
        guard let playback = musicPlayer.playbackTimeRange else { return [] }
        if duration <= 0.0 { return [] }
        if playback.lowerBound <= 0.0 { return [] }
        if playback.upperBound >= duration { return [] }
        let minRate = playback.lowerBound / duration
        let maxRate = playback.upperBound / duration
        return [minRate, maxRate]
    }
    
    private var trimmingDivisionRates: [Float] {
        let positions = musicPlayer.division?.values ?? []
        return positions.compactMap { value in
            if duration <= 0.0 { return nil }
            return value / duration
        }
    }
    
    private var positions: [Float] {
        if musicPlayer.playbackTimeRange != nil {
            return trimmingPositionRates
        }
        else {
            return trimmingDivisionRates
        }
    }
    
    init(showTrimmingPosition: Bool? = nil, duration: TimeInterval? = nil) {
        self.showTrimmingPosition = showTrimmingPosition
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let duration = musicPlayer.duration, duration > 0.0 {
                Slider(value: $musicPlayer.currentTime, in: 0.0...Float(duration), step: 0.1) { isEditing in
                    if isEditing {
                        musicPlayer.stopCurrentTimeRendering()
                    }
                    else {
                        musicPlayer.startCurrentTimeRendering()
                        musicPlayer.setSeek()
                    }
                }
                
                let positions = positions
                if !positions.isEmpty {
                    if showTrimmingPosition == true {
                        // Sliderと幅を揃えたいがSliderの内部で
                        // 微量のPaddingを含んでいるため微調整する
                        MiniPlayerTrimmingPositionView(positions: positions)
                            .padding(.horizontal, 1)
                            .padding(.vertical, 10)
                    }
                }
                
                MusicSecondsTexts(from: musicPlayer.currentTime, to: Float(duration), showDecimalSeconds: false)
            }
        }
    }
}

struct MusicPlaybackSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlaybackSliderView(duration: 300)
    }
}
