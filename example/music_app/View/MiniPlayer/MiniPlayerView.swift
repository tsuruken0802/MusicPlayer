//
//  MiniPlayerView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI

enum MiniPlayerLayoutType {
    case mini
    case normalExpanded
    case expandedAndShowList
    
    var isExpanded: Bool {
        return self == .normalExpanded || self == .expandedAndShowList
    }
    
    var imageSize: CGFloat {
        switch self {
        case .mini:
            return 50
        case .normalExpanded:
            return UIScreen.main.bounds.height / 3
        case .expandedAndShowList:
            return 50
        }
    }
}

struct MiniPlayer: View {
    let animation: Namespace.ID
    
    @State var layoutType: MiniPlayerLayoutType = .mini
    
    // Dragged y offset
    @State var draggingOffsetY: CGFloat = 0
    
    // Date at the start of dragging
    @State var startDraggingDate: Date?
    
    @State var isEditingSlideBar: Bool = false
    
    @State var presentation: MiniPlayerPresentation?
    
    @ObservedObject var musicPlayer = MusicPlayer.shared
    
    // song thumnbnail image size when mini player is large
    private let largeSongImageSize: CGFloat = UIScreen.main.bounds.height / 3
    
    // song thumnbnail image size when mini player is small
    private let smallSongImageSize: CGFloat = 50
    
    // playback icon size
    private let playbackIconSize: CGFloat = 40
    
    // mini player height
    static let miniPlayerHeight: CGFloat = 74
    
    private let optionIconSize: CGFloat = 30
    
    private let tabbarHeight: CGFloat = 48
    
    private var songName: String {
        return musicPlayer.currentItem?.title ?? "再生停止中"
    }
    
    private var artistName: String {
        return musicPlayer.currentItem?.artist ?? ""
    }
    
    private var isExpanded: Bool { return layoutType.isExpanded }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 15) {
                
                if layoutType == .normalExpanded {
                    Spacer()
                }
                
                VStack {
                    if layoutType == .normalExpanded {
                        Spacer()
                    }
                    
                    songImage
                        .cornerRadius(5)
                }
                
                if !isExpanded {
                    Text(songName)
                        .font(.body)
                }
                
                if layoutType == .expandedAndShowList {
                    VStack {
                        Text(songName)
                        
                        Text(artistName)
                    }
                }
                
                Spacer()
                
                // controllers
                if !isExpanded {
                    MiniPlayerControllerView()
                }
            }
            .padding(.horizontal, (MiniPlayer.miniPlayerHeight - smallSongImageSize) / 2)
            
            VStack(spacing: 0) {
                Spacer()
                
                if isExpanded {
                    Text(songName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text(artistName)
                        .font(.title3)
                }
                
                Spacer()
                
                // Slider
                MusicPlaybackSliderView(isEditingSlideBar: $isEditingSlideBar,
                                        showTrimmingPosition: true)
                    .padding(.horizontal)
                
                Spacer()
                
                // controller
                HStack {
                    Spacer()
                    Button {
                        musicPlayer.back()
                    } label: {
                        Image(systemName: "backward.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: playbackIconSize, height: playbackIconSize)
                            .foregroundColor(Color.primary)
                            .padding()
                    }
                    Spacer()
                    Button {
                        if musicPlayer.isPlaying {
                            musicPlayer.pause()
                        }
                        else {
                            musicPlayer.play()
                        }
                    } label: {
                        playAndPauseImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: playbackIconSize, height: playbackIconSize)
                            .foregroundColor(Color.primary)
                    }
                    Spacer()
                    Button {
                        musicPlayer.next()
                    } label: {
                        Image(systemName: "forward.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: playbackIconSize, height: playbackIconSize)
                            .foregroundColor(Color.primary)
                            .padding()
                    }
                    Spacer()
                }
                
                Spacer()
                
                // options
                HStack {
                    Spacer()
                    
                    Button {
                        presentation = .init(presentation: .optionView)
                    } label: {
                        Image(systemName: "music.quarternote.3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: optionIconSize, height: optionIconSize)
                            .padding(4)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if layoutType == .normalExpanded {
                                layoutType = .expandedAndShowList
                            }
                            else {
                                layoutType = .normalExpanded
                            }
                        }
                    } label: {
                        Image(systemName: "list.dash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: optionIconSize, height: optionIconSize)
                            .padding(4)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .sheet(item: $presentation, content: { $0.presentation })

                Spacer()
            }
            .frame(height: isExpanded ? nil : 0)
            .opacity(isExpanded ? 1 : 0)
        }
        .frame(maxHeight: isExpanded ? .infinity : MiniPlayer.miniPlayerHeight)
        .background(
            VStack(spacing: 0) {
                MiniPlayerBackgroundView()
                Divider()
            }
        )
        .cornerRadius(isExpanded ? 20 : 0)
        .offset(y: isExpanded ? draggingOffsetY : -tabbarHeight)
        .ignoresSafeArea()
        .gesture(DragGesture().onEnded(onEnded(value:)).onChanged(onChanged(value:)))
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { layoutType = .normalExpanded }
        }
    }
    
    @ViewBuilder
    private var songImage: some View {
        if let image = musicPlayer.currentItem?.artwork?.image(at: CGSize(width: layoutType.imageSize, height: layoutType.imageSize)) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: layoutType.imageSize, height: layoutType.imageSize)
        }
        else {
            NoImageView(size: layoutType.imageSize)
        }
    }
    
    private var playAndPauseImage: Image {
        return Image(systemName: musicPlayer.isPlaying ? "pause.fill" : "play.fill")
    }
    
    private func onChanged(value: DragGesture.Value) {
        if isEditingSlideBar {
            return
        }
        if startDraggingDate == nil {
            startDraggingDate = value.time
        }
        
        if value.translation.height > 0 && isExpanded {
            withAnimation(.interactiveSpring()) {
                draggingOffsetY = value.translation.height
            }
        }
    }
    
    private func onEnded(value: DragGesture.Value) {
        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.8)) {
            guard let dragTime = startDraggingDate else { return }
            // ドラッグしてから離してまでの秒数
            let second = value.time.timeIntervalSince(dragTime)
            // ドラッグの速度(px/秒)
            let velocity: CGFloat = CGFloat(value.translation.height) / CGFloat(second)
            // ある程度早い速度だったら閉じる
            if velocity > 1500 {
                layoutType = .mini
            }
            
            // ある程度の高さまでドラッグしていたら閉じる
            if value.translation.height > UIScreen.main.bounds.height / 3 {
                layoutType = .mini
            }
            
            draggingOffsetY = 0
            startDraggingDate = nil
        }
    }
}
