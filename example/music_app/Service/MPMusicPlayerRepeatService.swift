//
//  MPMusicPlayerRepeatService.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/02.
//

import Foundation

class MPMusicPlayerRepeatService {
    static func next() {
        switch MusicPlayer.shared.repeatType {
        case .list:
            MusicPlayer.shared.repeatType = .one
            
        case .one:
            MusicPlayer.shared.repeatType = .none
            
        case .none:
            MusicPlayer.shared.repeatType = .list
        }
    }
}
