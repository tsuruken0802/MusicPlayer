//
//  MusicSecondsTexts.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/04/22.
//

import SwiftUI

struct MusicSecondsTexts: View {
    let from: Float
    
    let to: Float
    
    let showDecimalSeconds: Bool
    
    init(from: Float, to: Float, showDecimalSeconds: Bool = false) {
        self.from = from
        self.to = to
        self.showDecimalSeconds = showDecimalSeconds
    }
    
    func secondsString(seconds: Float) -> String {
        if showDecimalSeconds {
            return PlayBackTimeConverter.toStringWithDecimal(seconds: seconds)
        }
        else {
            return PlayBackTimeConverter.toString(seconds: seconds)
        }
    }
    
    var body: some View {
        HStack {
            Text(secondsString(seconds: from))
            Spacer()
            Text(secondsString(seconds: to))
        }
    }
}

//struct MusicSecondsTexts_Previews: PreviewProvider {
//    static var previews: some View {
//        MusicSecondsTexts()
//    }
//}
