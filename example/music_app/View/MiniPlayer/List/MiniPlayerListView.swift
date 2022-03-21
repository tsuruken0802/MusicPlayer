//
//  MiniPlayerListView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import SwiftUI

struct MiniPlayerListView: View {
    @Environment(\.editMode) private var editMode
    
    @State var items: [MiniPlayerListItem]
    
    var body: some View {
        List {
            ForEach(items) { (item) in
                MiniPlayerListItemView(item: item)
            }
            .onMove { indexSet, index in
                items.move(fromOffsets: indexSet, toOffset: index)
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            editMode?.wrappedValue = .active
        }
        .onDisappear {
            editMode?.wrappedValue = .inactive
        }
    }
}

struct MiniPlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerListView(items: [
            .init(id: 1, image: nil, title: "タイトル1", artist: "アーティスト"),
            .init(id: 2, image: nil, title: "タイトル2", artist: "アーティスト"),
        ])
    }
}
