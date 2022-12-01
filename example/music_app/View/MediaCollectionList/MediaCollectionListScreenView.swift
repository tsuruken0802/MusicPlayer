//
//  MediaCollectionListScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import SwiftUI
import MediaPlayer

struct MediaCollectionListScreenView: View {
    
    @StateObject var viewModel: MediaCollectionListViewModel
    
    private let artistName: String
    
    private let itemCount: Int = 2
    
    private let itemWidth: CGFloat
    
    private let padding: CGFloat = 16
    
    private let columns: [GridItem]
    
    init(artistId: MPMediaEntityPersistentID, artistName: String) {
        _viewModel = StateObject<MediaCollectionListViewModel>(wrappedValue: .init(artistId: artistId))
        
        self.artistName = artistName
        
        // calculate item size
        let totalHPadding = padding * CGFloat(itemCount+1)
        itemWidth = (UIScreen.main.bounds.width - totalHPadding) / CGFloat(itemCount)
        
        columns = Array(repeating: .init(.fixed(itemWidth), spacing: padding), count: itemCount)
    }
    
    @ViewBuilder
    private func image(album: MPSongItem) -> some View {
        let itemHeight = itemWidth / 1.5
        if let image = album.artwork?.image(at: CGSize(width: itemWidth, height: itemHeight)) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: itemWidth, height: itemHeight)
                .cornerRadius(5)
        }
        else {
            NoImageView(size: itemWidth)
                .cornerRadius(5)
        }
    }
    
    private func subTitle(media: MPSongItem) -> String {
        if let year = media.item.year, year != 0 {
            return String(year)
        }
        else if let artist = media.item.artist {
            return artist
        }
        return ""
    }
    
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.mediaList.indices, id: \.self) { (index) in
                        VStack(alignment: .leading, spacing: 0) {
                            image(album: viewModel.mediaList[index])
                                .padding(.bottom, 6)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.mediaList[index].displayTitle ?? "")
                                    .font(.callout)
                                    .lineLimit(1)
                                
                                Text(subTitle(media: viewModel.mediaList[index]))
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                MusicPlayer.shared.play(items: viewModel.mediaList, index: index)
                            }
                        }
                    }
                }
            }
            .navigationTitle(artistName)
            .padding(.bottom, MiniPlayer.miniPlayerHeight)
        }
    }
}

struct MediaCollectionListScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MediaCollectionListScreenView(artistId: 0, artistName: "artist")
    }
}
