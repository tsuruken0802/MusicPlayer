//
//  MiniPlayerListHeaderView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import SwiftUI

struct MiniPlayerListHeaderView: View {
    
    @StateObject var musicPlayer = MusicPlayer.shared
    
    private var shuffleBg: some View {
        return musicPlayer.isShuffle ? Color.white.opacity(0.4) : Color.clear
    }
    
    private var repeatBg: some View {
        return  musicPlayer.isRepeat ? Color.white.opacity(0.4) : Color.clear
    }
    
    var body: some View {
        HStack {
            Text("次に再生")
                .font(.headline)
                .bold()
            
            Spacer()
            Button {
                musicPlayer.isShuffle.toggle()
            } label: {
                Image(systemName: "shuffle")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    .background(shuffleBg.cornerRadius(6))
            }
            .padding(.leading)
            
            Button {
                musicPlayer.isRepeat.toggle()
            } label: {
                Image(systemName: "repeat")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    .background(repeatBg.cornerRadius(6))
            }
        }
    }
}

struct MiniPlayerListHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerListHeaderView()
    }
}
