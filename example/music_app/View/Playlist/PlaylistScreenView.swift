//
//  PlaylistScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI
import AudioToolbox

struct PlaylistScreenView: View {
    @ObservedObject var viewModel = PlaylistScreenViewModel()
    
    @State var songListNavi: NavigationLinkData<SongListScreenView> = .init()
    
    private let imageSize: CGFloat = 90
    
    var body: some View {
        Group {
            VStack {
                List {
                    ForEach(viewModel.playlists) { (playlist) in
                        Button(action: {
                            let songItems = playlist.items.map({ MPSongItem(item: $0) })
                            songListNavi.destination = SongListScreenView(items: songItems)
                        }, label: {
                            HStack {
                                if let image = playlist.representativeItem?.artwork?.image(at: CGSize(width: imageSize, height: imageSize)) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: imageSize, height: imageSize)
                                        .cornerRadius(5)
                                }
                                else {
                                    NoImageView(size: imageSize)
                                        .cornerRadius(5)
                                }
                                
                                Text(playlist.playlistName ?? "名無し")
                                    .padding(.vertical, 12)
                                    .padding(.leading, 8)
                                    .font(.title3)
                            }
                        })
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("プレイリスト")
                
                NavigationLink(destination: songListNavi.destination, isActive: $songListNavi.activeNavigation) {
                    EmptyView()
                }
            }
            .padding(.bottom, MiniPlayer.miniPlayerHeight)
        }
    }
}

struct PlaylistScreenView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistScreenView()
    }
}
