//
//  File.swift
//  
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import Foundation

class MusicPlayerSerivce {
    /// Pitchの表示用の文字列を取得する
    /// - Parameter value: Pitchの値
    /// - Returns: 文字列
    static func displayPitch(value: Float) -> String {
        let sPitch = Int(value / Constants.Pitch.unit)
        var prefix = ""
        if sPitch > 0 {
            prefix = Constants.Pitch.plusMark
        }
        else if sPitch < 0 {
            prefix = Constants.Pitch.minusMark
        }
        return "\(prefix)\(abs(sPitch))"
    }
    
    /// Rate(テンポの速さ)の表示用の文字列を取得する
    /// - Parameter value: レートの値
    /// - Returns: 文字列
    static func displayRate(value: Float) -> String {
        let rate = value / Constants.Rate.defaultValue
        let prefix = "×"
        return "\(prefix)\(rate)"
    }
    
    /// 有効なPitchの値を取得する
    /// - Parameter value: Pitchの値
    /// - Returns: 有効値に変換された値
    static func enablePitchValue(value: Float) -> Float {
        return min(max(value, Constants.Pitch.limitMinValue), Constants.Pitch.limitMaxValue)
    }
    
    /// 有効なRateの値を取得する
    /// - Parameter value: Rateの値
    /// - Returns: 有効値に変換された値
    static func enableRateValue(value: Float) -> Float {
        return min(max(value, Constants.Rate.limitMinValue), Constants.Rate.limitMaxValue)
    }
}
