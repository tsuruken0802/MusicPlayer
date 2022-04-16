//
//  PlayerSettingScreenView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/16.
//

import SwiftUI

struct PlayerSettingScreenView: View {
    @StateObject private var viewModel = PlayerSettingViewModel()
    
    private func secondsString(_ seconds: Int) -> String {
        return "\(seconds)秒"
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Remote Command Skip Seconds")
                    Spacer()
                    Menu {
                        Picker("", selection: $viewModel.playerSeconds) {
                            Text(secondsString(5)).tag(5)
                            Text(secondsString(10)).tag(10)
                            Text(secondsString(15)).tag(15)
                        }
                    }
                    label: {
                        Text(secondsString(viewModel.playerSeconds))
                            .frame(width: 40)
                            .lineLimit(1)
                    }
                }
            }
            
            Section {
                HStack {
                    Text("Remote Command Is Skip")
                    Spacer()
                    Toggle(isOn: $viewModel.isSkip) {
                        
                    }
                }
            }
        }
        .navigationTitle("プレイヤー設定")
    }
}

struct PlayerSettingScreenView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSettingScreenView()
    }
}
