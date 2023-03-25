//
//  ShareFileService.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2023/03/25.
//

import Foundation
import UIKit

class ShareFileService {
    static func share(fileUrlPath: String) {
        let url = URL(fileURLWithPath: fileUrlPath)
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let viewController = scene?.keyWindow?.rootViewController
        viewController?.present(activityViewController, animated: true, completion: nil)
    }
}
