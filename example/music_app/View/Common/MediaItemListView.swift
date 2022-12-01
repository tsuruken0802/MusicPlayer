//
//  MediaItemListView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import SwiftUI
import MediaPlayer

enum MediaListType {
    case artwork
    case number
}

struct MediaItemListView: View {
    let items: [MPSongItem]
    
    let listType: MediaListType
    
    let onTap: (_ item: MPSongItem, _ index: Int) -> Void
    
    @ViewBuilder
    private func itemView(index: Int) -> some View {
        if listType == .number {
            MediaNumberItemView(number: index+1, title: items[index].displayTitle ?? "") {
                onTap(items[index], index)
            }
        }
        else if listType == .artwork {
            MediaThumbnailItemView(thumbnailImage: items[index].item.image(size: MediaThumbnailItemView.imageSize), title: items[index].displayTitle ?? "") {
                onTap(items[index], index)
            }
        }
        else {
            EmptyView()
        }
    }
    
    var body: some View {
        List {
            ForEach(items.indices, id: \.self) { (index) in
                /// VStackでラップしないとList表示が最適化されず
                /// 全てのViewを一気に全て読み込んでしまう
                VStack {
                    itemView(index: index)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MediaItemListView_Previews: PreviewProvider {
    static var previews: some View {
        MediaItemListView(items: [], listType: .artwork, onTap: { _,_  in
            
        })
    }
}
