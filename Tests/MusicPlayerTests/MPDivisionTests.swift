//
//  MPDivisionTests.swift
//  
//
//  Created by 鶴本賢太朗 on 2022/05/16.
//

import XCTest
import MusicPlayer

class MPDivisionTests: XCTestCase {
    func test_Divisionのfromとtoの値が正しいかどうか() {
        let value1: Float = 20.0
        let value2: Float = 100.0
        let value3: Float = 200.0
        let values: [Float] = [value1, value2, value3]
        let duration: Float = 300.0
        var division = MPDivision(values: values)
        XCTAssertEqual(division.fromValue(duration: duration), 0.0)
        XCTAssertEqual(division.toValue(duration: duration), value1)
        
        division.setCurrentIndex(currentTime: 150.0)
        XCTAssertEqual(division.fromValue(duration: duration), value2)
        XCTAssertEqual(division.toValue(duration: duration), value3)
        
        division.setCurrentIndex(currentTime: 20.0)
        XCTAssertEqual(division.fromValue(duration: duration), value1)
        XCTAssertEqual(division.toValue(duration: duration), value2)
        
        let division2 = MPDivision(values: [])
        XCTAssertEqual(division2.fromValue(duration: duration), 0.0)
        XCTAssertEqual(division2.toValue(duration: duration), 300)
    }
}

