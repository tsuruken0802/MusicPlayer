//
//  LibraryScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI

struct LibraryScreenView: View {
    @State var playlistNavi: NavigationLinkData<PlaylistScreenView> = .init()
    
    @State var artistNavi: NavigationLinkData<ArtistListScreenView> = .init()
    
    @State var songsNavi: NavigationLinkData<AllSongListScreenView> = .init()
    
    private let iconWrapSize: CGFloat = 24
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    HStack {
                        HStack {
                            Image(systemName: "music.note.list")
                        }
                        .frame(width: iconWrapSize)
                        
                        Button(action: {
                            playlistNavi.destination = PlaylistScreenView()
                        }, label: {
                            NavigationLink("プレイリスト", destination: playlistNavi.destination, isActive: $playlistNavi.activeNavigation)
                                .font(.title2)
                        })
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "music.mic")
                        }
                        .frame(width: iconWrapSize)

                        
                        Button(action: {
                            artistNavi.destination = ArtistListScreenView()
                        }, label: {
                            NavigationLink("アーティスト", destination: artistNavi.destination, isActive: $artistNavi.activeNavigation)
                                .font(.title2)
                        })
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "music.note")
                        }
                        .frame(width: iconWrapSize)
                        
                        Button(action: {
                            let allSongs = MPMediaService.getAllSongs().map({ MPSongItem(item: $0) })
                            songsNavi.destination = AllSongListScreenView(songs: allSongs)
                        }, label: {
                            NavigationLink("曲", destination: songsNavi.destination, isActive: $songsNavi.activeNavigation)
                                .font(.title2)
                        })
                    }
                    
                    HStack {
                        HStack {
                            Image(systemName: "music.note")
                        }
                        .frame(width: iconWrapSize)
                        
                        Button(action: {
                            let upRate = MusicPlayer.shared.incrementedRate(startRate: MPConstants.defaultRateValue)
                            let upPitch = MusicPlayer.shared.incrementedPitch(startPitch: MPConstants.defaultPitchValue)
                            let allSongs = MPMediaService.getAllSongs().map({ MPSongItem(item: $0, effect: .init(rate: upRate, pitch: upPitch, reverb: .init(value: 80, type: .largeHall2))) })
                            songsNavi.destination = AllSongListScreenView(songs: allSongs)
                        }, label: {
                            NavigationLink("曲(up rate)", destination: songsNavi.destination, isActive: $songsNavi.activeNavigation)
                                .font(.title2)
                        })
                    }
                }
                .padding(.vertical, 12)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("ライブラリ")
        }
    }
}

struct LibraryScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryScreenView()
    }
}
