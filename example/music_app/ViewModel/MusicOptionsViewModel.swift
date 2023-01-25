//
//  MusicOptionsViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/07.
//

import Foundation
import Combine

class MusicOptionsViewModel: ObservableObject {
    let pitchPlusMark: String = "#"
    let pitchMinusMark: String = "♭"
    
    @Published var selectedTrimmingIndex = 0
    let trimmingPickerTexts: [String] = [
        "分割",
        "トリミング"
    ]
    
    @Published var isLoopDivision: Bool
    
    @Published var selectedReverb: Int = 0
    
    private var cancellables: [AnyCancellable] = []
    
    init() {
        isLoopDivision = MusicPlayer.shared.division.loopDivision
        
        $isLoopDivision.sink { value in
            DispatchQueue.main.async {
                MusicPlayer.shared.division.loopDivision = value
            }
        }.store(in: &cancellables)
        $selectedReverb.sink { value in
            DispatchQueue.main.async {
                MusicPlayer.shared.reverbType = .init(rawValue: value)
            }
        }.store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { cancel in
            cancel.cancel()
        }
    }
    
    /// Pitchの表示用の文字列を取得する
    /// - Parameter value: Pitchの値
    /// - Parameter unit: スライダー一個分の値
    /// - Returns: 文字列
    func displayPitch(value: Float, unit: Float) -> String {
        if unit == 0.0 { return "" }
        
        let sPitch = Int(value / unit)
        var prefix = ""
        if sPitch > 0 {
            prefix = pitchPlusMark
        }
        else if sPitch < 0 {
            prefix = pitchMinusMark
        }
        return "\(prefix)\(abs(sPitch))"
    }
    
    /// Rate(テンポの速さ)の表示用の文字列を取得する
    /// - Parameter value: Rateの値
    /// - Parameter defaultValue: Rateのdefault
    /// - Returns: 文字列
    func displayRate(value: Float, defaultValue: Float) -> String {
        if defaultValue == 0.0 { return "" }
        
        let rate = value / defaultValue
        let prefix = "×"
        return "\(prefix)\(rate)"
    }
}
