//
//  music_appApp.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI
import MediaPlayer

@main
struct music_appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabScreenView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MPMediaLibrary.requestAuthorization { _ in
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        setAudioSession()
        return true
    }
}

private extension AppDelegate {
    /// set audio session
    func setAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        }
        catch let e {
            print(e.localizedDescription)
        }
    }
}
