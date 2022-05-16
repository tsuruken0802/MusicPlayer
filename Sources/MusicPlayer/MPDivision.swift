//
//  MPDivisions.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/22.
//

import Foundation

public struct MPDivision {
    private(set) public var values: [Float] = []
    
    let loopDivision: Bool
    
    private var fullDivisions: [Float] {
        return [0.0] + values
    }
    
    private var currentIndex: Int = 0
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
    
    public init(values: [Float] = [], currentTime: Float, loopDivision: Bool = false) {
        // remove duplicated
        let setArray = Array(Set(values))
        let sorted = setArray.sorted(by: {value1, value2 in
            return value1 < value2
        })
        self.values = sorted
        self.loopDivision = loopDivision
        setCurrentIndex(currentTime: currentTime)
    }
}

public extension MPDivision {
    // 現在の区間のfromの秒数を取得する
    func fromValue(duration: Float) -> Float {
        let fullDivisions = fullDivisions + [duration]
        if !fullDivisions.indices.contains(currentIndex) { return 0.0 }
        return fullDivisions[currentIndex]
    }
    
    // 現在の区間のtoの秒数を取得する
    func toValue(duration: Float) -> Float {
        let fullDivisions = fullDivisions + [duration]
        let index = currentIndex + 1
        if !fullDivisions.indices.contains(index) { return fullDivisions.last! }
        return fullDivisions[index]
    }
    
    // 一番近い戻り時間を取得する
    func backTime(currentTime: Float, threshold: Float? = nil) -> Float? {
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
}

public extension MPDivision {
    // 現在の区間のindexを設定する
    mutating func setCurrentIndex(currentTime: Float) {
        let time = max(currentTime, 0.0)
        let fullDivisions = fullDivisions
        for i in 0 ..< fullDivisions.count {
            if time < fullDivisions[i] {
                currentIndex = i - 1
                return
            }
        }
        currentIndex = fullDivisions.count - 1
    }
    
    // add division
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
    
    // remove division
    mutating func remove(index: Int) {
        if !values.indices.contains(index) { return }
        values.remove(at: index)
    }
    
    // clear divisions
    mutating func clear() {
        values.removeAll()
    }
}
