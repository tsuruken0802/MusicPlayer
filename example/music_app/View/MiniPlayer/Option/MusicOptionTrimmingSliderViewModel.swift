//
//  MusicOptionTrimmingSliderViewModel.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/20.
//

import Observation
import Combine

class MusicOptionTrimmingSliderViewModel: ObservableObject {
    @Published var currentValue: ClosedRange<Float> = 0.0...Float(MusicPlayer.shared.duration ?? 0.0)
    
    init() {
        _ = withObservationTracking {
            MusicPlayer.shared.playbackTimeRange
        } onChange: { [weak self] in
            if let value = MusicPlayer.shared.playbackTimeRange {
                self?.currentValue = value
            }
        }
    }
}
