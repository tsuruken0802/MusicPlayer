//
//  MiniPlayerListView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import SwiftUI

struct MiniPlayerListView: View {
    @StateObject private var viewModel: MiniPlayerListViewModel = .init()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(viewModel.currentItems) { (item) in
                    MiniPlayerListItemView(item: item)
                        .listRowBackground(Color.clear)
                }
                .onMove { indexSet, index in
                    viewModel.currentItems.move(fromOffsets: indexSet, toOffset: index)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
            
            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.4), .clear]), startPoint: .bottom, endPoint: .top)
                .frame(height: 30)
        }
    }
}

struct MiniPlayerListView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerListView()
            .environment(\.colorScheme, .dark)
            .frame(height: 300)
    }
}
