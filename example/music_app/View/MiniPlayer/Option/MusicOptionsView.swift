//
//  MusicOptionsView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/02/28.
//

import SwiftUI
import AVFAudio

struct ReverbData: Identifiable {
    var reverbType: AVAudioUnitReverbPreset
    var name: String
    
    public var id: String { String(reverbType.rawValue) }
}

extension AVAudioUnitReverbPreset: Identifiable {
    public var id: String { String(self.rawValue) }
}

struct MusicOptionsView: View {
    @State private var musicPlayer = MusicPlayer.shared
    @StateObject private var viewModel: MusicOptionsViewModel = .init()
    
    @State private var reverbSelection = [
        ReverbData(reverbType: .smallRoom, name: "狭い部屋"),
        ReverbData(reverbType: .mediumRoom, name: "普通の部屋"),
        ReverbData(reverbType: .largeRoom, name: "広い部屋"),
        ReverbData(reverbType: .largeRoom2, name: "広い部屋2"),
        ReverbData(reverbType: .mediumHall, name: "普通のホール"),
        ReverbData(reverbType: .mediumHall2, name: "普通のホール2"),
        ReverbData(reverbType: .mediumHall3, name: "普通のホール3"),
        ReverbData(reverbType: .largeHall, name: "広いホール"),
        ReverbData(reverbType: .largeHall2, name: "広いホール2"),
        ReverbData(reverbType: .plate, name: "プレート"),
        ReverbData(reverbType: .mediumChamber, name: "ミディアムチェンバー"),
        ReverbData(reverbType: .largeChamber, name: "大きいチェンバー"),
        ReverbData(reverbType: .cathedral, name: "大聖堂"),
    ]
    
    private var pitchString: String {
        return viewModel.displayPitch(value: musicPlayer.pitch, unit: musicPlayer.pitchOptions.unit)
    }
    
    private var rateString: String {
        return viewModel.displayRate(value: musicPlayer.rate, defaultValue: musicPlayer.rateOptions.defaultValue)
    }
    
    private var divisions: [Float] {
        let source = musicPlayer.division
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
                
                VStack {
                    Text("ライブエフェクト")
                        .font(.title2)
                        .topSpace()
                    
                    HStack {
                        Text("強さ")
                        Slider(value: $musicPlayer.reverbValue, in: musicPlayer.reverbOptions.minValue...musicPlayer.reverbOptions.maxValue, step: musicPlayer.reverbOptions.unit)
                    }
                    Picker("ライブエフェクトを選択", selection: $viewModel.selectedReverb) {
                        ForEach(reverbSelection) { reverbType in
                            Text(reverbType.name).tag(reverbType.reverbType.rawValue)
                        }
                    }
                }
                
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
                                
                                Toggle(isOn: $viewModel.isLoopDivision) {
                                    Text("区間内ループ")
                                }
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
