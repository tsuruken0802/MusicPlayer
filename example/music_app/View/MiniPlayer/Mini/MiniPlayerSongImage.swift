//
//  MiniPlayerSongImage.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/22.
//

import SwiftUI

struct MiniPlayerSongImage: View {
    @StateObject private var musicPlayer = MusicPlayer.shared
    
    let layoutType: MiniPlayerLayoutType
    
    @ViewBuilder
    private var songImage: some View {
        if let image = musicPlayer.currentItem?.artwork?.image(at: CGSize(width: layoutType.imageSize, height: layoutType.imageSize)) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: layoutType.imageSize, height: layoutType.imageSize)
        }
        else {
            NoImageView(size: layoutType.imageSize)
        }
    }
    
    var body: some View {
        songImage
    }
}

struct MiniPlayerSongImage_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerSongImage(layoutType: .mini)
    }
}
