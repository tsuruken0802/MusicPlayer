//
//  NoImageView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/25.
//

import SwiftUI

struct NoImageView: View {
    let size: Double
    
    var body: some View {
        ZStack {
            Color("noImageBg")
                .frame(width: size, height: size)
            
            Image(systemName: "music.note.list")
                .resizable()
                .frame(width: size / 2, height: size / 2)
                .foregroundColor(Color.red)
        }
    }
}

struct NoImageView_Previews: PreviewProvider {
    static var previews: some View {
        NoImageView(size: 50)
    }
}
