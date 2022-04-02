//
//  Audio.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
import AVFoundation

// reference: https://github.com/jgorset/Recorder/blob/master/Sources/Recording.swift

class AudioPlayer {
    private var session: AVAudioSession = .sharedInstance()
    private var player: AVAudioPlayer?
    private var url: URL

    init(url: URL) {
        self.url = url
    }

    func play() throws {
        try session.setCategory(.playback)

        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
