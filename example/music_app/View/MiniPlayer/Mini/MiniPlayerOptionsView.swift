//
//  MiniPlayerOptionsView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import SwiftUI

struct MiniPlayerOptionsView: View {
    @Binding var layoutType: MiniPlayerLayoutType
    
    @State private var presentation: MiniPlayerPresentation?
    
    private let optionIconSize: CGFloat = 30
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                presentation = .init(presentation: .optionView)
            } label: {
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: optionIconSize, height: optionIconSize)
                    .padding(4)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    if layoutType == .normalExpanded {
                        layoutType = .expandedAndShowList
                    }
                    else {
                        layoutType = .normalExpanded
                    }
                }
            } label: {
                Image(systemName: "list.dash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: optionIconSize, height: optionIconSize)
                    .padding(4)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .sheet(item: $presentation, content: { $0.presentation })
    }
}

struct MiniPlayerOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerOptionsView(layoutType: .constant(.mini))
    }
}
