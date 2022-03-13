//
//  TabScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI

struct TabScreenView: View {
    @State var isExpand = false
    
    @Namespace var animation
    
    @StateObject var musicPlayer: MusicPlayer = MusicPlayer.shared
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            TabView {
                LibraryScreenView()
                    .tabItem {
                        Image(systemName: "music.note")
                    }
            }
            .accentColor(Color.blue)
            
            MiniPlayer(animation: animation, expand: $isExpand)
                .transition(AnyTransition.offset().animation(.easeInOut))
        }
    }
}

struct TabScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TabScreenView()
    }
}
