//
//  MiniPlayerBackgroundView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI

struct MiniPlayerBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
