//
//  PlayerSettingViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/16.
//

import Foundation
import Combine

class PlayerSettingViewModel: ObservableObject {
    @Published var playerSeconds: Int
    
    @Published var isSkip: Bool = MusicPlayer.shared.rightRemoteCommand.isSkipType
    
    private var cancellable: [AnyCancellable] = []
    
    init() {
        playerSeconds = 15
        
        $playerSeconds.sink { value in
            MusicPlayer.shared.remoteSkipSeconds = value
        }
        .store(in: &cancellable)
        
        $isSkip.sink { value in
            MusicPlayer.shared.rightRemoteCommand = value ? .skipForward : .nextTrack
            MusicPlayer.shared.leftRemoteCommand = value ? .skipBackward : .previousTrack
        }
        .store(in: &cancellable)
    }
}

