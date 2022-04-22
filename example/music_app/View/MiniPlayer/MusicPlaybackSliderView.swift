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
    
    private var trimmingPositions: [Float] {
        if let playbackTimeRange = musicPlayer.playbackTimeRange {
            if duration <= 0.0 { return [] }
            return [playbackTimeRange.lowerBound / duration, playbackTimeRange.upperBound / duration]
        }
        return musicPlayer.division.values
    }
    
    private var trimmingPositionRates: [Float] {
        let positions = trimmingPositions
        return positions.compactMap { value in
            if duration <= 0.0 { return nil }
            return value / Float(duration)
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
                        musicPlayer.startCurrentTimeRedering()
                        musicPlayer.setSeek()
                    }
                }
                
                let positions = trimmingPositionRates
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
