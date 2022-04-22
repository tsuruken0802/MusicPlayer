//
//  MusicPlayerDivisionView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/22.
//

import SwiftUI

struct MusicPlayerDivisionView: View {
    @StateObject private var musicPlayer: MusicPlayer = .shared
    
    let duration: TimeInterval
    
    let divisions: [Float]
    
    private let circleLength: CGFloat = 28
    
    private let verticalSpacing: CGFloat = 20
    
    @State var value: Float = 0
    
    var valueRate: Float? {
        if duration <= 0 { return nil } // 0割禁止
        return musicPlayer.currentTime / Float(duration)
    }
    
    private func circle(width: CGFloat) -> some View {
        let rate = CGFloat(valueRate ?? 0.0)
        let x: CGFloat = (width - circleLength) * rate
        return Image(systemName: "plus.circle.fill")
            .resizable()
            .foregroundColor(.green)
            .frame(width: circleLength, height: circleLength)
            .padding(.leading, x)
    }
    
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
                circle(width: geometry.size.width)
                    .onTapGesture {
                        musicPlayer.division.add(seconds: musicPlayer.currentTime)
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

struct MusicPlayerDivisionView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerDivisionView(duration: 300, divisions: [0, 0.1, 0.5, 1])
    }
}
