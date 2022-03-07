//
//  File.swift
//  
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import Foundation

@available(iOS 13.0, *)
public class MPConstants {
    /// Pitch
    public static let defaultPitchValue: Float = 0.0
    public static let defaultPitchMinValue: Float = -800
    public static let defaultPitchMaxValue: Float = 800
    public static let defaultPitchUnit: Float = 100
    public static let limitPitchMinValue: Float = -2400
    public static let limitPitchMaxValue: Float = 2400
    
    /// Rate
    public static let defaultRateValue: Float = 1.0
    public static let defaultRateMinValue: Float = 0.25
    public static let defaultRateMaxValue: Float = 4.0
    public static let defaultRateUnit: Float = 0.25
    public static let limitRateMinValue: Float = 0.25
    public static let limitRateMaxValue: Float = 4.0
}
