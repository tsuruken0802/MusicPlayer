//
//  ArtistAlbumListScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/03.
//

import SwiftUI
import MediaPlayer

struct ArtistAlbumListScreenView: View {
    
    @StateObject var viewModel: ArtistAlbumListViewModel
    
    @State var songListNavi: NavigationLinkData<SongListScreenView> = .init()
    
    private let artistName: String
    
    private let itemCount: Int = 2
    
    private let itemSize: CGFloat
    
    private let padding: CGFloat = 16
    
    private let columns: [GridItem]
    
    init(artistId: MPMediaEntityPersistentID, artistName: String) {
        _viewModel = StateObject<ArtistAlbumListViewModel>(wrappedValue: .init(artistId: artistId))
        
        self.artistName = artistName
        
        // calculate item size
        let totalHPadding = padding * CGFloat(itemCount+1)
        itemSize = (UIScreen.main.bounds.width - totalHPadding) / CGFloat(itemCount)
        
        columns = Array(repeating: .init(.fixed(itemSize), spacing: padding), count: itemCount)
    }
    
    private func subTitle(album: MPMediaItem) -> String {
        if let year = album.year, year != 0 {
            return String(year)
        }
        else if let artist = album.artist {
            return artist
        }
        return ""
    }
    
    @ViewBuilder
    private func image(album: MPMediaItem) -> some View {
        if let image = album.artwork?.image(at: CGSize(width: itemSize, height: itemSize)) {
            Image(uiImage: image)
                .resizable()
                .frame(width: itemSize, height: itemSize)
                .cornerRadius(5)
        }
        else {
            NoImageView(size: itemSize)
                .cornerRadius(5)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.albums) { (album) in
                        VStack(alignment: .leading, spacing: 0) {
                            image(album: album)
                                .padding(.bottom, 6)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(album.albumTitle ?? "")
                                    .font(.callout)
                                    .lineLimit(1)
                                
                                Text(subTitle(album: album))
                                    .font(.callout)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                        .onTapGesture {
                            songListNavi.destination = SongListScreenView(items: MPMediaService.getSongs(albumPersistentID: album.albumPersistentID))
                        }
                    }
                }
            }
            .navigationTitle(artistName)
            .padding(.bottom, MiniPlayer.miniPlayerHeight)
        
            NavigationLink(destination: songListNavi.destination, isActive: $songListNavi.activeNavigation) {
                EmptyView()
            }
        }
    }
}

struct ArtistAlbumScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistAlbumListScreenView(artistId: 0, artistName: "artist name")
    }
}
