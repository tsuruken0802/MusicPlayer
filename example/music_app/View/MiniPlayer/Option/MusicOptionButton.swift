//
//  MusicOptionButton.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/02/27.
//

import SwiftUI

struct MusicOptionButton: View {
    let title: String
    
    let font: Font
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(title)
                .font(font)
                .foregroundColor(.white)
                .frame(minWidth: 100)
                .frame(height: 50)
                .background(Color.green)
                .cornerRadius(6)
        }
    }
}

struct MusicOptionButton_Previews: PreviewProvider {
    static var previews: some View {
        MusicOptionButton(title: "標準", font: .title3, onTap: {
            
        })
            .frame(width: 200, height: 100)
    }
}
