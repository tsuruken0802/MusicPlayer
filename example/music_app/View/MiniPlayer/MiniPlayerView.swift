//
//  MiniPlayerView.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2021/12/24.
//

import SwiftUI
import MusicPlayer

struct MiniPlayer: View {
    let animation: Namespace.ID
    
    @Binding var expand: Bool
    
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
    
    private var artistName: String? {
        return musicPlayer.currentItem?.artist
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 15) {
                
                if expand {
                    Spacer(minLength: 0)
                }
                
                VStack {
                    if expand {
                        Spacer()
                    }

                    songImage
                        .cornerRadius(5)
                }
                
                if !expand, let songName = self.songName {
                    Text(songName)
                        .font(.body)
                }
                
                Spacer()
                
                // controllers
                if !expand {
                    Button {
                        if musicPlayer.isPlaying {
                            musicPlayer.pause()
                        }
                        else {
                            musicPlayer.play()
                        }
                    } label: {
                        playAndPauseImage
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(6)
                    }
                    
                    Button {
                        musicPlayer.next()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(6)
                    }
                }
            }
            .padding(.horizontal, (MiniPlayer.miniPlayerHeight - smallSongImageSize) / 2)
            
            VStack(spacing: 0) {
                Spacer()
                
                if expand, let songName = self.songName, let artistName = self.artistName {
                    Text(songName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Text(artistName)
                        .font(.title3)
                }
                Spacer()
                
                // Slider
                VStack {
                    if let duration = musicPlayer.duration {
                        Slider(value: $musicPlayer.currentTime, in: 0...Float(duration), step: 0.1) { isEditing in
                            isEditingSlideBar = isEditing
                            if isEditing {
                                musicPlayer.stopCurrentTimeTimer()
                            }
                            else {
                                musicPlayer.startCurrentTimeTimer()
                            }
                            if !isEditing {
                                musicPlayer.setSeek(withPlay: musicPlayer.isPlaying)
                            }
                        }
                    }
                    HStack {
                        Text(PlayBackTimeConverter.toString(seconds: musicPlayer.currentTime))
                        Spacer()
                        Text(PlayBackTimeConverter.toString(seconds:  Float(musicPlayer.duration ?? 0)))
                    }
                }
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
                    Button {
                        presentation = .init(presentation: .optionView)
                    } label: {
                        Image(systemName: "music.quarternote.3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: optionIconSize, height: optionIconSize)
                            .padding(4)
                    }
                    .padding(.horizontal)
                }
                .sheet(item: $presentation) {
                    
                } content: { $0.presentation }
                
                Spacer()
            }
            .frame(height: expand ? nil : 0)
            .opacity(expand ? 1 : 0)
        }
        .frame(maxHeight: expand ? .infinity : MiniPlayer.miniPlayerHeight)
        .background(
            VStack(spacing: 0) {
                MiniPlayerBackgroundView()
                Divider()
            }
        )
        .cornerRadius(expand ? 20 : 0)
        .offset(y: expand ? draggingOffsetY : -tabbarHeight)
        .ignoresSafeArea()
        .gesture(DragGesture().onEnded(onEnded(value:)).onChanged(onChanged(value:)))
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { expand = true }
        }
    }
    
    @ViewBuilder
    private var songImage: some View {
        let size = expand ? largeSongImageSize : smallSongImageSize
        if let image = musicPlayer.currentItem?.artwork?.image(at: CGSize(width: size, height: size)) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
        }
        else {
            NoImageView(size: size)
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
        
        if value.translation.height > 0 && expand {
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
                expand = false
            }
            
            // ある程度の高さまでドラッグしていたら閉じる
            if value.translation.height > UIScreen.main.bounds.height / 3 {
                expand = false
            }
            
            draggingOffsetY = 0
            startDraggingDate = nil
        }
    }
}
