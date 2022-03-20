//
//  MusicOptionsView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/02/28.
//

import SwiftUI
import RangeSlider

struct MusicOptionsView: View {    
    @ObservedObject var musicPlayer = MusicPlayer.shared
    
    @StateObject var viewModel: MusicOptionsViewModel = .init()
    
    @State var currentValue: ClosedRange<Float> = MusicPlayer.shared.minPlaybackTime...MusicPlayer.shared.maxPlaybackTime
    
    private var pitchString: String {
        return viewModel.displayPitch(value: musicPlayer.pitch, unit: musicPlayer.pitchOptions.unit)
    }
    
    private var rateString: String {
        return viewModel.displayRate(value: musicPlayer.rate, defaultValue: musicPlayer.rateOptions.defaultValue)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // tempo
                VStack {
                    Text("テンポコントロール")
                        .font(.title2)
                        .verticalSpace()
                    
                    Text(rateString)
                        .font(.title)
                        .fontWeight(.bold)
                        .verticalSpace()
                    
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
                    .verticalSpace()
                }
                .largeVerticalSpace()
                
                // key
                VStack {
                    Text("キーコントロール")
                        .font(.title2)
                        .verticalSpace()
                    
                    Text(pitchString)
                        .font(.title)
                        .fontWeight(.bold)
                        .verticalSpace()
                    
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
                    .verticalSpace()
                }
                .largeVerticalSpace()
                
                // key
                VStack {
                    Text("トリミング")
                        .font(.title2)
                        .verticalSpace()
                    
                    RangeSlider(currentValue: $currentValue,
                                bounds: musicPlayer.minPlaybackTime...musicPlayer.maxPlaybackTime,
                                isOverRange: true,
                                tintColor: Color.green) { isEditing in
                    }
                    
                    HStack {
                        Text(PlayBackTimeConverter.toString(seconds: Float(currentValue.lowerBound)))
                        Spacer()
                        Text(PlayBackTimeConverter.toString(seconds: Float(currentValue.upperBound)))
                    }
                    
                    MusicPlaybackSliderView()
                }
                .largeVerticalSpace()
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
    func verticalSpace() -> some View {
        return self
            .padding(.top, 16)
    }
    
    func largeVerticalSpace() -> some View {
        return self
            .padding(.top, 32)
    }
}
