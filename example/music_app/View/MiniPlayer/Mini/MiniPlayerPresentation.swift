//
//  MiniPlayerPresentation.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/04.
//

import Foundation
import SwiftUI

struct MiniPlayerPresentation: Identifiable {
    enum Presentation: View {
        case optionView
        
        var body: some View {
            switch self {
            case .optionView:
                return AnyView(MusicOptionsView())
            }
        }
    }
    
    var id: String = UUID().uuidString
    
    var presentation: Presentation?
    
    init(presentation: Presentation?) {
        self.presentation = presentation
    }
}

