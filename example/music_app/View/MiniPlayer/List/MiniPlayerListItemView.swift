//
//  MiniPlayerListItemView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import SwiftUI

struct MiniPlayerListItemView: View {
    let item: MiniPlayerListItem
    
    var body: some View {
        HStack {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: MediaThumbnailItemView.imageSize, height: MediaThumbnailItemView.imageSize)
                    .cornerRadius(5)
            }
            else {
                NoImageView(size: MediaThumbnailItemView.imageSize)
                    .cornerRadius(5)
            }
            VStack(alignment: .leading) {
                Text(item.title)
                    .lineLimit(1)
                
                if let artist = item.artist {
                    Text(artist)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

struct MiniPlayerListItemView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerListItemView(item: .init(id: 10, image: nil, title: "あいうえお", artist: "あいみょん"))
    }
}
