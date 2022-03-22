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
    
    // song thumnbnail image size when mini player is small
    private let smallSongImageSize: CGFloat = 50
    
    // mini player height
    static let miniPlayerHeight: CGFloat = 72
    
    private let tabbarHeight: CGFloat = 48
    
    private var isExpanded: Bool { return layoutType.isExpanded }
    
    private var isNormalExpanded: Bool { return layoutType == .normalExpanded }
    
    private var isMini: Bool { return layoutType == .mini }
    
    private var isShowList: Bool { return layoutType == .expandedAndShowList }
    
    private var horizontalPadding: CGFloat {
        if isMini {
            return (MiniPlayer.miniPlayerHeight - smallSongImageSize) / 2
        }
        else {
            return 20
        }
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
                        MiniPlayerSongImage(layoutType: layoutType)
                            .cornerRadius(5)
                        
                        if isShowList {
                            MiniPlayerShowListSongNameView()
                            
                            Spacer()
                        }
                        
                        if isMini {
                            MiniPlayerMiniContentView()
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    
                    if isShowList {
                        Group {
                            MiniPlayerListHeaderView()
                                .frame(height: 30)
                                .padding(.top, 20)
                            
                            MiniPlayerListView()
                                .padding(.top, 10)
                        }
                        .padding(.horizontal, horizontalPadding)
                    }
                    
                    if isNormalExpanded {
                        Spacer()
                        
                        MiniPlayerExpandedSongNameView()
                    }
                }
                .frame(height: UIScreen.main.bounds.height / 1.5)
                
                // controller
                if isExpanded {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        
                        // Slider
                        MusicPlaybackSliderView(isEditingSlideBar: $isEditingSlideBar,
                                                showTrimmingPosition: true)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 0)
                        
                        // controller
                        MiniPlayerExpanedControllerView()
                        
                        Spacer(minLength: 0)
                        
                        MiniPlayerOptionsView(layoutType: $layoutType)
                        
                        Spacer(minLength: 0)
                        Spacer(minLength: 0)
                    }
                }
            }
            .frame(maxHeight: isExpanded ? .infinity : MiniPlayer.miniPlayerHeight)
            .background(
                VStack(spacing: 0) {
                    MiniPlayerBackgroundView()
                    if isMini {
                        Divider()
                    }
                }
                    .gesture(DragGesture().onEnded(onEnded(value:)).onChanged(onChanged(value:)), including: .gesture)
                    .gesture(TapGesture().onEnded {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if layoutType == .mini {
                                layoutType = .normalExpanded
                            }
                        }
                    }, including: .all)
            )
            .cornerRadius(isExpanded ? 20 : 0)
            .offset(y: isExpanded ? draggingOffsetY : miniOffset(bottomSafeArea: geometry.safeAreaInsets.bottom))
            .ignoresSafeArea()
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
