//
//  PlaybackTimeConverter.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/02/24.
//

import Foundation

class PlayBackTimeConverter {
    /// 時間を文字列に変換する
    /// seconds: 秒数
    /// return: 「0:00」のフォーマットの文字列
    static func toString(seconds: Float) -> String {
        let sSeconds = Int(seconds)
        let min = sSeconds / 60
        let remain = sSeconds % 60
        let strRemain = remain < 10 ? "0\(remain)" : String(remain)
        return "\(min):\(strRemain)"
    }
    
    /// 時間を文字列に変換する
    /// seconds: 秒数
    /// return: 「0:00」のフォーマットの文字列
    static func toStringWithDecimal(seconds: Float) -> String {
        let sSeconds = Int(seconds)
        let min = sSeconds / 60
        let fraction = seconds.truncatingRemainder(dividingBy: 1)
        let remain = Float(sSeconds % 60) + fraction
        let roundStrRemain = String(format: "%.1f", remain)
        let strRemain = remain < 10 ? "0\(roundStrRemain)" : String(roundStrRemain)
        return "\(min):\(strRemain)"
    }
}
