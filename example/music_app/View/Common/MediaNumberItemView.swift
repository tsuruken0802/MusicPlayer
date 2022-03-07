//
//  MediaNumberItemView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import SwiftUI

struct MediaNumberItemView: View {
    let number: Int
    
    let title: String
    
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Text(String(number))
                    .frame(minWidth: 30)
                    .foregroundColor(.gray)
                
                Text(title)
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
        }
    }
}

struct MediaNumberItemView_Previews: PreviewProvider {
    static var previews: some View {
        MediaNumberItemView(number: 100, title: "あいうえお", onTap: {})
    }
}
