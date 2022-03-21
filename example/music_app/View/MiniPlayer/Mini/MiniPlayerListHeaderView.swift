//
//  MiniPlayerListHeaderView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import SwiftUI

struct MiniPlayerListHeaderView: View {
    
    private var iconBg: some View {
        Color.gray.opacity(0.05).cornerRadius(6)
    }
    
    var body: some View {
        HStack {
            Text("次に再生")
                .font(.headline)
                .bold()
            
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "shuffle")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    .background(iconBg)
            }
            .padding(.leading)
            
            Button {
                
            } label: {
                Image(systemName: "repeat")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    .background(iconBg)
            }
        }
    }
}

struct MiniPlayerListHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerListHeaderView()
    }
}
