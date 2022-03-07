//
//  ScreenHelper.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/25.
//

import UIKit

class ScreenHelper {
    static var safeArea: UIEdgeInsets? {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets
    }
}
