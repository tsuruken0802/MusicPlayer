//
//  File.swift
//  
//
//  Created by 鶴本賢太朗 on 2022/03/06.
//

import Foundation

@available(iOS 13.0, *)
public final class MPConstants {
    
    public struct Pitch {
        public static var minValue: Float {
            return -800
        }
        
        public static var maxValue: Float {
            return 800
        }
        
        /// デバイスの限界値
        public static var limitMinValue: Float {
            return -2400
        }
        
        /// デバイスの限界値
        public static var limitMaxValue: Float {
            return 2400
        }
        
        public static var unit: Float {
            return 100
        }
        
        public static let defaultValue: Float = 0.0
        
        public static let plusMark: String = "#"
        
        public static let minusMark: String = "♭"
    }

    public struct Rate {
        public static var minValue: Float {
            return 0.25
        }
        
        public static var maxValue: Float {
            return 4.0
        }
        
        /// デバイスの限界値
        public static var limitMinValue: Float {
            return 0.25
        }
        
        /// デバイスの限界値
        public static var limitMaxValue: Float {
            return 4.0
        }
        
        public static var unit: Float {
            return 0.25
        }
        
        public static var defaultValue: Float = 1.0
        
        public static let plusMark: String = "+"
        
        public static let minusMark: String = "-"
    }
}

