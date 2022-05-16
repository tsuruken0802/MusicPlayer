//
//  MusicOptionsView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/02/28.
//

import SwiftUI

struct MusicOptionsView: View {
    @ObservedObject private var musicPlayer = MusicPlayer.shared
    
    @StateObject private var viewModel: MusicOptionsViewModel = .init()
    
    private var pitchString: String {
        return viewModel.displayPitch(value: musicPlayer.pitch, unit: musicPlayer.pitchOptions.unit)
    }
    
    private var rateString: String {
        return viewModel.displayRate(value: musicPlayer.rate, defaultValue: musicPlayer.rateOptions.defaultValue)
    }
    
    private var divisions: [Float] {
        guard let source = musicPlayer.division else { return [] }
        let duration = musicPlayer.fDuration
        if duration <= 0 { return [] }
        return source.values.map({ $0 / duration })
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // tempo
                VStack {
                    Text("テンポコントロール")
                        .font(.title2)
                        .topSpace()
                    
                    Text(rateString)
                        .font(.title)
                        .fontWeight(.bold)
                        .topSpace()
                    
                    Slider(value: $musicPlayer.rate, in: musicPlayer.rateOptions.minValue...musicPlayer.rateOptions.maxValue, step: musicPlayer.rateOptions.unit)

                    // tempo buttons
                    HStack {
                        MusicOptionButton(title: "-", font: .title) {
                            musicPlayer.decrementRate()
                        }
                        Spacer()
                        MusicOptionButton(title: "標準", font: .title3) {
                            musicPlayer.resetRate()
                        }
                        Spacer()
                        MusicOptionButton(title: "+", font: .title) {
                            musicPlayer.incrementRate()
                        }
                    }
                    .topSpace()
                }
                .largeTopSpace()
                
                // key
                VStack {
                    Text("キーコントロール")
                        .font(.title2)
                        .topSpace()
                    
                    Text(pitchString)
                        .font(.title)
                        .fontWeight(.bold)
                        .topSpace()
                    
                    Slider(value: $musicPlayer.pitch,
                           in: musicPlayer.pitchOptions.minValue...musicPlayer.pitchOptions.maxValue,
                           step: musicPlayer.pitchOptions.unit)
                    
                    // key buttons
                    HStack {
                        MusicOptionButton(title: viewModel.pitchMinusMark, font: .title) {
                            musicPlayer.decrementPitch()
                        }
                        Spacer()
                        MusicOptionButton(title: "標準", font: .title3) {
                            musicPlayer.resetPitch()
                        }
                        Spacer()
                        MusicOptionButton(title: viewModel.pitchPlusMark, font: .title) {
                            musicPlayer.incrementPitch()
                        }
                    }
                    .topSpace()
                }
                .largeTopSpace()
                
                // trimming
                VStack {
                    Text("トリミング")
                        .font(.title2)
                        .topSpace()
                    
                    Picker("", selection: $viewModel.selectedTrimmingIndex) {
                        ForEach(viewModel.trimmingPickerTexts.indices, id: \.self) { index in
                            Text(viewModel.trimmingPickerTexts[index])
                                 .tag(index)
                         }
                     }
                     .pickerStyle(SegmentedPickerStyle())
                    
                    Group {
                        if viewModel.selectedTrimmingIndex == 0 {
                            if let duration = musicPlayer.duration {
                                MusicPlayerDivisionView(duration: duration, divisions: divisions)
                            }
                        }
                        else {
                            MusicOptionTrimmingSliderView()

                            MusicPlaybackSliderView(duration: musicPlayer.duration)
                        }
                    }
                    .topSpace()
                }
                .largeTopSpace()
                
                Spacer(minLength: 32)
            }
            .padding(.horizontal)
        }
    }
}

struct MusicOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        MusicOptionsView()
    }
}

private extension View {
    func topSpace() -> some View {
        return self
            .padding(.top, 16)
    }
    
    func largeTopSpace() -> some View {
        return self
            .padding(.top, 32)
    }
}
