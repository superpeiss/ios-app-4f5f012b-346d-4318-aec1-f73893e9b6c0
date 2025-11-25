import UIKit
import AVFoundation
import Speech

class RecordingViewController: UIViewController {
    private let audioRecordingManager = AudioRecordingManager()
    private let fillerWordDetector = FillerWordDetector()
    private let storageManager = StorageManager.shared

    private let timerLabel = UILabel()
    private let recordButton = UIButton(type: .system)
    private let statusLabel = UILabel()

    private var isRecording = false
    private var currentRecording: Recording?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioManager()
        requestPermissions()
    }

    private func setupUI() {
        title = "New Recording"
        view.backgroundColor = .systemBackground

        // Timer label
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 48, weight: .medium)
        timerLabel.textAlignment = .center
        timerLabel.text = "00:00.0"
        view.addSubview(timerLabel)

        // Status label
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 16, weight: .regular)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .secondaryLabel
        statusLabel.text = "Press record to start"
        view.addSubview(statusLabel)

        // Record button
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Start Recording", for: .normal)
        recordButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        recordButton.backgroundColor = .systemRed
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.layer.cornerRadius = 35
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        view.addSubview(recordButton)

        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),

            statusLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            recordButton.widthAnchor.constraint(equalToConstant: 250),
            recordButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func setupAudioManager() {
        audioRecordingManager.delegate = self
    }

    private func requestPermissions() {
        audioRecordingManager.requestPermissions { [weak self] granted in
            if !granted {
                self?.showError("Microphone access is required to record audio.")
            }
        }

        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                DispatchQueue.main.async {
                    self.showError("Speech recognition access is required for filler word detection.")
                }
            }
        }
    }

    @objc private func recordButtonTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        do {
            try audioRecordingManager.startRecording(title: "New Recording")
            isRecording = true
            updateUI(forRecording: true)
        } catch {
            showError("Failed to start recording: \(error.localizedDescription)")
        }
    }

    private func stopRecording() {
        audioRecordingManager.stopRecording()
        isRecording = false
        updateUI(forRecording: false)
    }

    private func updateUI(forRecording recording: Bool) {
        if recording {
            recordButton.setTitle("Stop Recording", for: .normal)
            recordButton.backgroundColor = .systemGray
            statusLabel.text = "Recording..."
        } else {
            recordButton.setTitle("Start Recording", for: .normal)
            recordButton.backgroundColor = .systemRed
            statusLabel.text = "Processing..."
            recordButton.isEnabled = false
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
    }

    private func analyzeRecording(_ recording: Recording) {
        statusLabel.text = "Analyzing audio..."

        fillerWordDetector.analyzeAudio(at: recording.audioFileURL) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let analysis):
                    let updatedRecording = recording.withAnalysis(analysis)
                    self.saveRecording(updatedRecording)

                case .failure(let error):
                    print("Analysis failed: \(error)")
                    // Save recording without analysis
                    self.saveRecording(recording)
                }
            }
        }
    }

    private func saveRecording(_ recording: Recording) {
        do {
            try storageManager.saveRecording(recording)
            navigationController?.popViewController(animated: true)
        } catch {
            showError("Failed to save recording: \(error.localizedDescription)")
            recordButton.isEnabled = true
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension RecordingViewController: AudioRecordingManagerDelegate {
    func audioRecordingManager(_ manager: AudioRecordingManager, didUpdateTime time: TimeInterval) {
        timerLabel.text = formatTime(time)
    }

    func audioRecordingManager(_ manager: AudioRecordingManager, didFinishRecording recording: Recording?) {
        guard let recording = recording else {
            showError("Recording failed")
            recordButton.isEnabled = true
            return
        }

        currentRecording = recording
        analyzeRecording(recording)
    }

    func audioRecordingManager(_ manager: AudioRecordingManager, didFailWithError error: Error) {
        showError("Recording error: \(error.localizedDescription)")
        recordButton.isEnabled = true
    }
}
