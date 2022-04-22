//
//  MPDivisions.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/22.
//

import Foundation

@available(iOS 13.0, *)
public struct MPDivision {
    private(set) var values: [Float] = []
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
}

@available(iOS 13.0, *)
public extension MPDivision {
    func from(currentTime: Float) -> Float? {
        if values.isEmpty { return nil }
        
        var from: Float = 0.0
        for i in 0 ..< values.count {
            if currentTime < values[i] {
                break
            }
            from = values[i]
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
    mutating func add(seconds: Float) {
        if values.contains(seconds) {
            return
        }
        values.append(seconds)
        values.sort { value1, value2 in
            return value1 < value2
        }
    }
    
    mutating func remove(index: Int) {
        if !values.indices.contains(index) { return }
        values.remove(at: index)
    }
    
    mutating func clear() {
        values.removeAll()
    }
}
