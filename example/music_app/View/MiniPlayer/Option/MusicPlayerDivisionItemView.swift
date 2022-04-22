//
//  MusicPlayerDivisionItemView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/22.
//

import SwiftUI

struct MusicPlayerDivisionItemView: View {
    let divisions: [Float]
    
    @State var value: Float = 0
    
    private var circle: some View {
        Image(systemName: "plus.circle.fill")
            .resizable()
            .foregroundColor(.green)
    }
    
    private static let closeLength: CGFloat = 20
    
    private static let rectangleWidth: CGFloat = 4
    
    private static let barHeight: CGFloat = 4
    
    private static let verticalSpace: CGFloat = 10
    
    static var height: CGFloat {
        MusicPlayerDivisionItemView.barHeight + MusicPlayerDivisionItemView.verticalSpace + MusicPlayerDivisionItemView.closeLength
    }
    
    private func rectangle(rate: Float, width: CGFloat) -> some View {
        let fRate = CGFloat(rate)
        let x = width * fRate
        return Rectangle()
            .frame(width: MusicPlayerDivisionItemView.rectangleWidth,
                   height: MusicPlayerDivisionItemView.barHeight)
            .foregroundColor(.green)
            .contentShape(Rectangle())
            .position(x: x, y: MusicPlayerDivisionItemView.barHeight / 2)
    }
    
    private func close(rate: Float, width: CGFloat) -> some View {
        let fRate = CGFloat(rate)
        let x = width * fRate - MusicPlayerDivisionItemView.closeLength/2
        return Image(systemName: "xmark.circle")
            .resizable()
            .foregroundColor(.gray)
            .frame(width: MusicPlayerDivisionItemView.closeLength, height: MusicPlayerDivisionItemView.closeLength)
            .padding(.leading, x)
    }
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(Color(UIColor.label.withAlphaComponent(0.15)))
                .frame(height: MusicPlayerDivisionItemView.barHeight)
                .overlay(
                    ZStack {
                        ForEach(divisions, id: \.self) { division in
                            rectangle(rate: division, width: geometry.size.width)
                        }
                    }
                )
            
            ForEach(divisions, id: \.self) { division in
                close(rate: division, width: geometry.size.width)
            }
            .padding(.top, MusicPlayerDivisionItemView.barHeight + MusicPlayerDivisionItemView.verticalSpace)
        }
        .frame(height: MusicPlayerDivisionItemView.height)
    }
}

struct MusicPlayerDivisionItemView_Previews: PreviewProvider {
    static var previews: some View {
        MusicPlayerDivisionItemView(divisions: [0, 0.1, 0.5, 1])
    }
}

