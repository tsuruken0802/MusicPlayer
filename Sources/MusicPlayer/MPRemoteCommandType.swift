//
//  MPRemoteCommandType.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/16.
//

import Foundation

@available(iOS 13.0, *)
public enum MPRemoteCommandType: Int {
    case nextTrack
    
    case previousTrack
    
    case skipForward
    
    case skipBackward
    
    var isSkipType: Bool {
        return self == .skipForward || self == .skipBackward
    }
}
