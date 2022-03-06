//
//  File.swift
//  
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import Foundation

public final class MPConstants {
    
    public struct Pitch {
        static var minValue: Float {
            return -800
        }
        
        static var maxValue: Float {
            return 800
        }
        
        /// デバイスの限界値
        static var limitMinValue: Float {
            return -2400
        }
        
        /// デバイスの限界値
        static var limitMaxValue: Float {
            return 2400
        }
        
        static var unit: Float {
            return 100
        }
        
        static let defaultValue: Float = 0.0
        
        static let plusMark: String = "#"
        
        static let minusMark: String = "♭"
    }

    public struct Rate {
        static var minValue: Float {
            return 0.25
        }
        
        static var maxValue: Float {
            return 4.0
        }
        
        /// デバイスの限界値
        static var limitMinValue: Float {
            return 0.25
        }
        
        /// デバイスの限界値
        static var limitMaxValue: Float {
            return 4.0
        }
        
        static var unit: Float {
            return 0.25
        }
        
        static var defaultValue: Float = 1.0
        
        static let plusMark: String = "+"
        
        static let minusMark: String = "-"
    }
}

