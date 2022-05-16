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
        return [0.0] + values
    }
    
    private var currentIndex: Int = 0
    
    public func fromValue(duration: Float) -> Float {
        let fullDivisions = fullDivisions + [duration]
        if !fullDivisions.indices.contains(currentIndex) { return 0.0 }
        return fullDivisions[currentIndex]
    }
    
    public func toValue(duration: Float) -> Float {
        let fullDivisions = fullDivisions + [duration]
        let index = currentIndex + 1
        if !fullDivisions.indices.contains(index) { return fullDivisions.last! }
        return fullDivisions[index]
    }
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
    
    public init(values: [Float] = []) {
        // remove duplicated
        let setArray = Array(Set(values))
        let sorted = setArray.sorted(by: {value1, value2 in
            return value1 < value2
        })
        self.values = sorted
    }
}

public extension MPDivision {
    mutating func setCurrentIndex(currentTime: Float) {
        let fullDivisions = fullDivisions
        for i in 0 ..< fullDivisions.count {
            if currentTime < fullDivisions[i] {
                currentIndex = i - 1
                return
            }
        }
        currentIndex = fullDivisions.count - 1
    }
    
    mutating func add(seconds: Float) {
        // 0秒以下は無効
        if seconds < 0 { return }
        // すでにあるなら追加しない
        if values.contains(seconds) { return }
        
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
