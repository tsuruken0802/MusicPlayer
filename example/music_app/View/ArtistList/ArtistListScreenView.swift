//
//  ArtistListScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI

struct ArtistListScreenView: View {
    @StateObject var viewModel: ArtistListViewModel = .init()
    
    @State var artistAlbumLink: NavigationLinkData<ArtistAlbumListScreenView> = .init()
    
    @State var mediaCollectionLink: NavigationLinkData<MediaCollectionListScreenView> = .init()
    
    private let imageSize: CGFloat = MediaThumbnailItemView.imageSize
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.artists) { (artist) in
                    MediaThumbnailItemView(thumbnailImage: artist.image(size: imageSize), title: artist.artist ?? "") {
                        // two or more albums
                        if artist.mediaType == .music {
                            artistAlbumLink.destination = ArtistAlbumListScreenView(artistId: artist.artistPersistentID, artistName: artist.artist ?? "")
                        }
                        else {
                            mediaCollectionLink.destination = MediaCollectionListScreenView(artistId: artist.artistPersistentID, artistName: artist.artist ?? "")
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("アーティスト")
            .padding(.bottom, MiniPlayer.miniPlayerHeight)
            
            NavigationLink(destination: artistAlbumLink.destination, isActive: $artistAlbumLink.activeNavigation) {
                EmptyView()
            }
            
            NavigationLink(destination: mediaCollectionLink.destination, isActive: $mediaCollectionLink.activeNavigation) {
                EmptyView()
            }
        }
    }
}

struct ArtistListScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistListScreenView()
    }
}
