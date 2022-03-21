//
//  AVAudioHelper.swift
//  music_app
//
//  Created by 鶴本賢太朗 on 2022/03/21.
//

import AVFAudio

class AVAudioHelper {
    static func audioFile(url: URL) -> AVAudioFile? {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            return audioFile
        }
        catch let e {
            print(e.localizedDescription)
            return nil
        }
    }
    
    static func readBuffer(url: URL) -> AVAudioPCMBuffer? {
        do {
            guard let audioFile = audioFile(url: url) else { return nil }
            let audioFrameCount = AVAudioFrameCount(audioFile.length)
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: audioFrameCount)
            try audioFile.read(into: audioBuffer!)
            return audioBuffer
        }
        catch let e {
            print(e.localizedDescription)
            return nil
        }
    }
}
