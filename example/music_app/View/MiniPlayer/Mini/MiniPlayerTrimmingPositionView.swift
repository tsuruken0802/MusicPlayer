//
//  MusicTrimmingPositionView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import SwiftUI

struct MiniPlayerTrimmingPositionView: View {
    let positions: [Float]
    
    private let rectangleWidth: CGFloat = 4
    
    private let barHeight: CGFloat = 4
    
    private let sliderCircleSize: CGFloat = 28
    
    private func rectangle(rate: Float, width: CGFloat) -> some View {      let fRate = CGFloat(rate)
        let x = width * fRate
        return Rectangle()
            .frame(width: rectangleWidth,
                   height: barHeight)
            .foregroundColor(.green)
            .contentShape(Rectangle())
            .position(x: x, y: barHeight/2)
    }
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(Color(UIColor.label.withAlphaComponent(0.15)))
                .frame(height: barHeight)
                .overlay(
                    ZStack {
                        ForEach(positions, id: \.self) { position in
                            rectangle(rate: position, width: geometry.size.width)
                        }
                    }
                )
        }
        .frame(height: barHeight)
    }
}

struct MusicTrimmingPositionView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerTrimmingPositionView(positions: [0.2, 0.8])
    }
}
