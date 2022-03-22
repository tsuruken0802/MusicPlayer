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
            return UIScreen.main.bounds.height / 2.5
        case .expandedAndShowList:
            return 50
        }
    }
}

struct MiniPlayer: View {
    let animation: Namespace.ID
    
    @State private var layoutType: MiniPlayerLayoutType = .mini
    
    // Dragged y offset
    @State private var draggingOffsetY: CGFloat = 0
    
    // Date at the start of dragging
    @State private var startDraggingDate: Date?
    
    @State private var isEditingSlideBar: Bool = false
    
    @StateObject private var musicPlayer = MusicPlayer.shared
    
    @StateObject private var viewModel: MiniPlayerViewModel = .init()
    
    // song thumnbnail image size when mini player is small
    private let smallSongImageSize: CGFloat = 50
    
    // mini player height
    static let miniPlayerHeight: CGFloat = 74
    
    private let tabbarHeight: CGFloat = 48
    
    private var songName: String {
        return musicPlayer.currentItem?.title ?? "再生停止中"
    }
    
    private var artistName: String {
        return musicPlayer.currentItem?.artist ?? ""
    }
    
    private var isExpanded: Bool { return layoutType.isExpanded }
    
    private var isNormalExpanded: Bool { return layoutType == .normalExpanded }
    
    private var isMini: Bool { return layoutType == .mini }
    
    private var isShowList: Bool { return layoutType == .expandedAndShowList }
    
    private var horizontalPadding: CGFloat {
        return (MiniPlayer.miniPlayerHeight - smallSongImageSize) / 2
    }
    
    private func miniOffset(bottomSafeArea: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.height - bottomSafeArea - tabbarHeight - MiniPlayer.miniPlayerHeight
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if isNormalExpanded {
                        Spacer()
                        Spacer()
                    }
                    
                    if isShowList {
                        Spacer(minLength: geometry.safeAreaInsets.top + 20)
                    }
                    
                    HStack(spacing: 15) {
                        songImage
                            .cornerRadius(5)
                        
                        if isShowList {
                            VStack(alignment: .leading) {
                                Text(songName)
                                
                                Text(artistName)
                            }
                            
                            Spacer()
                        }
                    
                        if isMini {
                            Text(songName)
                                .lineLimit(1)
                                .font(.body)
                            
                            Spacer()
                            
                            MiniPlayerMiniControllerView()
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    
                    if isShowList {
                        Group {
                            MiniPlayerListHeaderView()
                                .frame(height: 30)
                                .padding(.top, 20)
                                
                            MiniPlayerListView(items: viewModel.currentItems)
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                        }
                        .padding(.horizontal, horizontalPadding)
                    }
                    
                    if isNormalExpanded {
                        Spacer()
                        
                        Text(songName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 10)
                        
                        Text(artistName)
                            .font(.title2)
                        
                        Spacer()
                    }
                }
                .frame(height: UIScreen.main.bounds.height / 1.55)
                
                // controller
                if isExpanded {
                    VStack(spacing: 0) {
                        // Slider
                        MusicPlaybackSliderView(isEditingSlideBar: $isEditingSlideBar,
                                                showTrimmingPosition: true)
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        // controller
                        MiniPlayerExpanedControllerView()
                        
                        Spacer()
                    }
                }
                
                // option button
                if isExpanded {
                    // options
                    MiniPlayerOptionsView(layoutType: $layoutType)

                    Spacer(minLength: 30)
                }
            }
            .frame(maxHeight: isExpanded ? .infinity : MiniPlayer.miniPlayerHeight)
            .background(
                VStack(spacing: 0) {
                    MiniPlayerBackgroundView()
                    Divider()
                }
            )
            .cornerRadius(isExpanded ? 20 : 0)
            .offset(y: isExpanded ? draggingOffsetY : miniOffset(bottomSafeArea: geometry.safeAreaInsets.bottom))
            .ignoresSafeArea()
            .gesture(DragGesture().onEnded(onEnded(value:)).onChanged(onChanged(value:)))
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { layoutType = .normalExpanded }
            }
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
