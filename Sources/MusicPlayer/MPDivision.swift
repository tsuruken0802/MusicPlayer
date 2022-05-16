//
//  MPDivisions.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/22.
//

import Foundation

public struct MPDivision {
    private(set) public var values: [Float] = []
    
    private var fullDivisions: [Float] {
        return [0.0] + values + [duration]
    }
    
    private var currentIndex: Int = 0
    
    private let duration: Float
    
    public var fromValue: Float {
        let fullDivisions = fullDivisions
        if !fullDivisions.indices.contains(currentIndex) { return 0.0 }
        return fullDivisions[currentIndex]
    }
    
    public var toValue: Float {
        let fullDivisions = fullDivisions
        let index = currentIndex + 1
        if !fullDivisions.indices.contains(index) { return 0.0 }
        return fullDivisions[index]
    }
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
    
    public init(values: [Float] = [], duration: Float) {
        // remove duplicated
        let setArray = Array(Set(values))
        let sorted = setArray.sorted(by: {value1, value2 in
            return value1 < value2
        })
        self.values = sorted
        
        self.duration = duration
    }
}

public extension MPDivision {
    func from(currentTime: Float, threshold: Float? = nil) -> Float? {
        if values.isEmpty { return nil }
        
        var from: Float = 0.0
        let totalTime = currentTime - (threshold ?? 0.0)
        for i in 0 ..< values.count {
            if totalTime < values[i] {
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
