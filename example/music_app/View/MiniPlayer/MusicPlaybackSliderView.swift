//
//  MusicPlaybackSliderView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import SwiftUI

struct MusicPlaybackSliderView: View {
    private let musicPlayer = MusicPlayer.shared

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
        let positions = musicPlayer.division.values
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

    // currentTimeを読まない親View(trimming/division オーバーレイの再評価を4Hz更新から守る)
    var body: some View {
        VStack(spacing: 0) {
            if let duration = musicPlayer.duration, duration > 0.0 {
                _PlaybackSliderInner(duration: Float(duration))

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

                _PlaybackSecondsLabel(duration: Float(duration))
            }
        }
    }
}

/// SliderのみcurrentTimeをBindする独立View
/// 4Hz再描画の影響をこの内側のSliderだけに局所化する
private struct _PlaybackSliderInner: View {
    private let musicPlayer = MusicPlayer.shared
    let duration: Float

    var body: some View {
        @Bindable var time = musicPlayer.time
        Slider(value: $time.currentTime, in: 0.0...duration, step: 0.1) { isEditing in
            if isEditing {
                musicPlayer.stopCurrentTimeRendering()
            }
            else {
                musicPlayer.startCurrentTimeRendering()
                musicPlayer.setSeek()
            }
        }
    }
}

/// 秒数ラベルもcurrentTime観測を独立Viewに切り出して局所化する
private struct _PlaybackSecondsLabel: View {
    private let playbackTime = MusicPlayer.shared.time
    let duration: Float

    var body: some View {
        MusicSecondsTexts(from: playbackTime.currentTime, to: duration, showDecimalSeconds: false)
    }
}

struct MusicPlaybackSliderView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlaybackSliderView(duration: 300)
    }
}
