import Foundation
import AVFoundation

protocol AudioPlaybackManagerDelegate: AnyObject {
    func audioPlaybackManager(_ manager: AudioPlaybackManager, didUpdateTime time: TimeInterval)
    func audioPlaybackManagerDidFinishPlaying(_ manager: AudioPlaybackManager)
    func audioPlaybackManager(_ manager: AudioPlaybackManager, didFailWithError error: Error)
}

class AudioPlaybackManager: NSObject {
    weak var delegate: AudioPlaybackManagerDelegate?

    private var audioPlayer: AVAudioPlayer?
    private var playbackTimer: Timer?

    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }

    var currentTime: TimeInterval {
        return audioPlayer?.currentTime ?? 0
    }

    var duration: TimeInterval {
        return audioPlayer?.duration ?? 0
    }

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func loadAudio(from url: URL) throws {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        } catch {
            throw error
        }
    }

    func play() {
        guard let player = audioPlayer else { return }
        player.play()
        startTimer()
    }

    func pause() {
        audioPlayer?.pause()
        stopTimer()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        stopTimer()
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        delegate?.audioPlaybackManager(self, didUpdateTime: time)
    }

    private func startTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.audioPlaybackManager(self, didUpdateTime: self.currentTime)
        }
    }

    private func stopTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}

extension AudioPlaybackManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        delegate?.audioPlaybackManagerDidFinishPlaying(self)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            delegate?.audioPlaybackManager(self, didFailWithError: error)
        }
    }
}
