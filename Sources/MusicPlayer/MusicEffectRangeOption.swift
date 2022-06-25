//
//  File.swift
//  
//
//  Created by 鶴本賢太朗 on 2022/03/07.
//

import Foundation

public struct MusicEffectRangeOption {
    public let minValue: Float
    public let maxValue: Float
    public let unit: Float
    public let defaultValue: Float
    
    public init(minValue: Float,
                maxValue: Float,
                unit: Float,
                defaultValue: Float) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.unit = unit
        self.defaultValue = defaultValue
    }
}
