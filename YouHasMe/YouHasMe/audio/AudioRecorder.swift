//
//  AudioRecorder.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
import AVFoundation
import Combine

class AudioRecorder {
    private var session: AVAudioSession = .sharedInstance()
    private var bitRate = 192_000
    private var sampleRate = 44_100.0
    private var channels = 1
    private var recorder: AVAudioRecorder?
    private var link: CADisplayLink?
    private var recordingURL: URL
    var isMeteringEnabled = true
    var meterPublisher: AnyPublisher<Float, Never> {
        meter.eraseToAnyPublisher()
    }
    private var meter: PassthroughSubject<Float, Never> = PassthroughSubject()

    init(recordingURL: URL) {
        self.recordingURL = recordingURL
    }

    init(recordingURL: URL, isMeteringEnabled: Bool) {
        self.recordingURL = recordingURL
        self.isMeteringEnabled = isMeteringEnabled
    }

    func prepare() throws {
        let settings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: Int32(kAudioFormatAppleLossless)),
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: bitRate,
            AVNumberOfChannelsKey: channels,
            AVSampleRateKey: sampleRate
        ]

        recorder = try AVAudioRecorder(url: recordingURL, settings: settings)
        recorder?.prepareToRecord()
        recorder?.isMeteringEnabled = isMeteringEnabled
    }

    func record() throws {
        if recorder == nil {
            try prepare()
        }

        try session.setCategory(.playAndRecord)
        try session.overrideOutputAudioPort(.speaker)

        recorder?.record()

        if isMeteringEnabled {
            startMetering()
        }
    }

    @objc
    func updateMeter() {
        guard let recorder = recorder else {
            return
        }

        recorder.updateMeters()

        let dB = recorder.averagePower(forChannel: 0)
        meter.send(dB)
    }

    private func startMetering() {
        link = CADisplayLink(target: self, selector: #selector(updateMeter))
    }

    private func stopMetering() {
        link?.invalidate()
        link = nil
    }
}
