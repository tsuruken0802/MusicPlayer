//
//  MusicPlayerDivisionView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/22.
//

import SwiftUI

struct MusicPlayerDivisionView: View {
    private let musicPlayer: MusicPlayer = .shared

    let duration: TimeInterval

    let divisions: [Float]

    private let circleLength: CGFloat = 28

    private let verticalSpacing: CGFloat = 20

    @State var value: Float = 0

    private var height: CGFloat {
        circleLength +
        verticalSpacing +
        30 +    // sliderの分
        verticalSpacing +
        MusicPlayerDivisionItemView.height
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                // currentTimeを観測する円アイコンは独立Viewに切り出し、
                // 4Hz更新の影響範囲をこの円のみに局所化する
                DivisionCircleView(duration: duration, circleLength: circleLength, width: geometry.size.width)
                    .onTapGesture {
                        musicPlayer.addDivision(seconds: musicPlayer.time.currentTime)
                    }

                Spacer(minLength: verticalSpacing)

                MusicPlaybackSliderView(duration: duration)

                Spacer(minLength: verticalSpacing)

                MusicPlayerDivisionItemView(divisions: divisions)
            }
        }
        .frame(height: height)
    }
}

private struct DivisionCircleView: View {
    private let playbackTime = MusicPlayer.shared.time
    let duration: TimeInterval
    let circleLength: CGFloat
    let width: CGFloat

    private var valueRate: Float? {
        if duration <= 0 { return nil } // 0割禁止
        return playbackTime.currentTime / Float(duration)
    }

    var body: some View {
        let rate = CGFloat(valueRate ?? 0.0)
        let x: CGFloat = (width - circleLength) * rate
        return Image(systemName: "plus.circle.fill")
            .resizable()
            .foregroundColor(.green)
            .frame(width: circleLength, height: circleLength)
            .padding(.leading, x)
    }
}

struct MusicPlayerDivisionView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerDivisionView(duration: 300, divisions: [0, 0.1, 0.5, 1])
    }
}
