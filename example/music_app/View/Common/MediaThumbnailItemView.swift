//
//  MediaItemView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import SwiftUI
import MediaPlayer

struct MediaThumbnailItemView: View {
    let thumbnailImage: UIImage?
    
    let title: String
    
    let onTap: () -> Void
    
    static let imageSize: CGFloat = 50
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: MediaThumbnailItemView.imageSize, height: MediaThumbnailItemView.imageSize)
                        .cornerRadius(5)
                }
                else {
                    NoImageView(size: MediaThumbnailItemView.imageSize)
                        .cornerRadius(5)
                }
                
                Text(title)
                    .lineLimit(1)
                    .padding(.leading, 4)
            }
        }
    }
}

struct MediaThumbnailItemView_Previews: PreviewProvider {
    static var previews: some View {
        MediaThumbnailItemView(thumbnailImage: nil, title: "かきくけこ", onTap: {})
    }
}
