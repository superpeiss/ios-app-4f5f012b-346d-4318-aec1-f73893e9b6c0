import Foundation
import AVFoundation

protocol AudioRecordingManagerDelegate: AnyObject {
    func audioRecordingManager(_ manager: AudioRecordingManager, didUpdateTime time: TimeInterval)
    func audioRecordingManager(_ manager: AudioRecordingManager, didFinishRecording recording: Recording?)
    func audioRecordingManager(_ manager: AudioRecordingManager, didFailWithError error: Error)
}

class AudioRecordingManager: NSObject {
    weak var delegate: AudioRecordingManagerDelegate?

    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var startTime: Date?
    private var recordingFileURL: URL?

    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }

    var currentTime: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func startRecording(title: String) throws {
        guard !isRecording else { return }

        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).m4a")
        recordingFileURL = audioFilename

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            startTime = Date()
            startTimer()
        } catch {
            throw error
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        audioRecorder?.stop()
        stopTimer()

        if let fileURL = recordingFileURL, let startTime = startTime {
            let duration = Date().timeIntervalSince(startTime)
            let recording = Recording(
                title: "Recording \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))",
                duration: duration,
                audioFileURL: fileURL
            )
            delegate?.audioRecordingManager(self, didFinishRecording: recording)
        }
    }

    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.audioRecordingManager(self, didUpdateTime: self.currentTime)
        }
    }

    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension AudioRecordingManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            delegate?.audioRecordingManager(self, didFinishRecording: nil)
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            delegate?.audioRecordingManager(self, didFailWithError: error)
        }
    }
}
