//
//  PlaybackTimeConverterTest.swift
//  music_appTests
//
//  Created by 鶴本賢太朗 on 2022/02/24.
//

import XCTest

class PlaybackTimeConverterTests: XCTestCase {
    func test_秒数の文字列が正しいか() {
        let str1 = PlayBackTimeConverter.toString(seconds: 60)
        let str2 = PlayBackTimeConverter.toString(seconds: 255)
        let str3 = PlayBackTimeConverter.toString(seconds: 301)
        let str4 = PlayBackTimeConverter.toString(seconds: 0)
        let str5 = PlayBackTimeConverter.toString(seconds: 1)
        let str6 = PlayBackTimeConverter.toString(seconds: 30)
        
        XCTAssertEqual(str1, "1:00")
        XCTAssertEqual(str2, "4:15")
        XCTAssertEqual(str3, "5:01")
        XCTAssertEqual(str4, "0:00")
        XCTAssertEqual(str5, "0:01")
        XCTAssertEqual(str6, "0:30")
    }
}
