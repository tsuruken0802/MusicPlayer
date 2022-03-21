//
//  MusicTrimmingPositionView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import SwiftUI

struct MusicTrimmingPositionView: View {
    let lowerRate: Float?
    
    let upperRate: Float?
    
    private let rectangleWidth: CGFloat = 4
    
    private let barHeight: CGFloat = 4
    
    private let sliderCircleSize: CGFloat = 28
    
    private func rectangle(rate: Float, width: CGFloat) -> some View {
        return Rectangle()
            .frame(width: rectangleWidth,
                   height: barHeight)
            .foregroundColor(.green)
            .contentShape(Rectangle())
            .position(x: (width - sliderCircleSize) * CGFloat(rate), y: barHeight / 2)
    }
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(Color(UIColor.label.withAlphaComponent(0.15)))
                .frame(height: barHeight)
                .overlay(
                    ZStack {
                        if let lowerRate = lowerRate {
                            rectangle(rate: lowerRate, width: geometry.size.width)
                        }
                        
                        if let upperRate = upperRate {
                            rectangle(rate: upperRate, width: geometry.size.width)
                        }
                    }
                )
        }
        .frame(height: barHeight)
    }
}

struct MusicTrimmingPositionView_Previews: PreviewProvider {
    static var previews: some View {
        MusicTrimmingPositionView(lowerRate: 0.2, upperRate: 0.8)
    }
}
