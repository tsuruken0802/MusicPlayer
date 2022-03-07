//
//  NavigationLinkData.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import Foundation
import SwiftUI

/// navigation link data
struct NavigationLinkData<T: View> {
    
    // navigation destination
    var destination: T? {
        didSet {
            self.activeNavigation = destination != nil
        }
    }
    
    // active navigation
    var activeNavigation: Bool = false
}
