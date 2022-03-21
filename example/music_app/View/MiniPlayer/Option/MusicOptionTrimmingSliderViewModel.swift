//
//  MusicOptionTrimmingSliderViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import Combine

class MusicOptionTrimmingSliderViewModel: ObservableObject {
    @Published var currentValue: ClosedRange<Float> = 0.0...Float(MusicPlayer.shared.duration ?? 0.0)
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        MusicPlayer.shared.$playbackTimeRange.sink { [weak self] value in
            if let value = value {
                self?.currentValue = value
            }
        }
        .store(in: &cancellables)
    }
}
