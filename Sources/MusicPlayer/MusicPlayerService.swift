//
//  File.swift
//  
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import Foundation

class MusicPlayerSerivce {
    /// 有効なPitchの値を取得する
    /// - Parameter value: Pitchの値
    /// - Returns: 有効値に変換された値
    static func enablePitchValue(value: Float) -> Float {
        return min(max(value, MPConstants.limitPitchMinValue), MPConstants.limitPitchMaxValue)
    }
    
    /// 有効なRateの値を取得する
    /// - Parameter value: Rateの値
    /// - Returns: 有効値に変換された値
    static func enableRateValue(value: Float) -> Float {
        return min(max(value, MPConstants.limitRateMinValue), MPConstants.limitRateMaxValue)
    }
}
