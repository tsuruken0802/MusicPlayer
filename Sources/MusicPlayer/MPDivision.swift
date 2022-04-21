//
//  MPDivisions.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/22.
//

import Foundation

@available(iOS 13.0, *)
public class MPDivision {
    private var values: [Float] = []
}

@available(iOS 13.0, *)
public extension MPDivision {
    func from(currentTime: Float) -> Float? {
        if values.isEmpty { return nil }
        
        var from: Float = currentTime
        for i in 0 ..< values.count {
            if from < values[i] {
                break
            }
            from = values[i]
        }
        // Returns 0 if the current time is the minimum
        if from == currentTime {
            return 0.0
        }
        return from
    }
    
    func to(currentTime: Float, duration: Float) -> Float? {
        if values.isEmpty { return nil }
        
        for i in 0 ..< values.count {
            if currentTime < values[i] {
                return values[i]
            }
        }
        return duration
    }
}


@available(iOS 13.0, *)
public extension MPDivision {
    func add(seconds: Float) {
        values.append(seconds)
        values.sort { value1, value2 in
            return value1 < value2
        }
    }
    
    func remove(index: Int) {
        values.remove(at: index)
    }
    
    func clear() {
        values.removeAll()
    }
}
