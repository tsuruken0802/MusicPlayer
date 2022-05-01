//
//  MPRemoteCommandType.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/16.
//

import Foundation

public enum MPRemoteCommandType: Int {
    case nextTrack = 0
    
    case previousTrack = 1
    
    case skipForward = 2
    
    case skipBackward = 3
    
    public var isSkipType: Bool {
        return self == .skipForward || self == .skipBackward
    }
}
