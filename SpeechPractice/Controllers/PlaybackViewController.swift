import UIKit

class PlaybackViewController: UIViewController {
    private let recording: Recording
    private let audioPlaybackManager = AudioPlaybackManager()
    private let storageManager = StorageManager.shared

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    private let timelineView = TimelineView()
    private let currentTimeLabel = UILabel()
    private let remainingTimeLabel = UILabel()
    private let progressSlider = UISlider()
    private let playButton = UIButton(type: .system)
    private let fillerWordsCountLabel = UILabel()
    private let wpmLabel = UILabel()
    private let fillerWordsListView = UITextView()

    init(recording: Recording) {
        self.recording = recording
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioManager()
        loadAudio()
        updateFillerWordsDisplay()
    }

    private func setupUI() {
        title = "Playback"
        view.backgroundColor = .systemBackground

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.text = recording.title
        view.addSubview(titleLabel)

        // Date
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        dateLabel.text = DateFormatter.localizedString(from: recording.date, dateStyle: .medium, timeStyle: .short)
        view.addSubview(dateLabel)

        // Timeline view
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.backgroundColor = .systemGray5
        timelineView.layer.cornerRadius = 8
        if let analysis = recording.analysisResults {
            timelineView.configure(duration: recording.duration, fillerWords: analysis.fillerWords)
        }
        view.addSubview(timelineView)

        // Time labels
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        currentTimeLabel.textColor = .secondaryLabel
        currentTimeLabel.text = "00:00"
        view.addSubview(currentTimeLabel)

        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingTimeLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        remainingTimeLabel.textColor = .secondaryLabel
        remainingTimeLabel.textAlignment = .right
        remainingTimeLabel.text = formatTime(recording.duration)
        view.addSubview(remainingTimeLabel)

        // Progress slider
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(recording.duration)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        view.addSubview(progressSlider)

        // Play button
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Play", for: .normal)
        playButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        playButton.backgroundColor = .systemBlue
        playButton.setTitleColor(.white, for: .normal)
        playButton.layer.cornerRadius = 25
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        view.addSubview(playButton)

        // Filler words count
        fillerWordsCountLabel.translatesAutoresizingMaskIntoConstraints = false
        fillerWordsCountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        fillerWordsCountLabel.numberOfLines = 0
        view.addSubview(fillerWordsCountLabel)

        // WPM label
        wpmLabel.translatesAutoresizingMaskIntoConstraints = false
        wpmLabel.font = .systemFont(ofSize: 14, weight: .regular)
        wpmLabel.textColor = .secondaryLabel
        view.addSubview(wpmLabel)

        // Filler words list
        fillerWordsListView.translatesAutoresizingMaskIntoConstraints = false
        fillerWordsListView.font = .systemFont(ofSize: 14, weight: .regular)
        fillerWordsListView.isEditable = false
        fillerWordsListView.backgroundColor = .systemGray6
        fillerWordsListView.layer.cornerRadius = 8
        view.addSubview(fillerWordsListView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            timelineView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 30),
            timelineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timelineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timelineView.heightAnchor.constraint(equalToConstant: 60),

            currentTimeLabel.topAnchor.constraint(equalTo: timelineView.bottomAnchor, constant: 10),
            currentTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            remainingTimeLabel.topAnchor.constraint(equalTo: timelineView.bottomAnchor, constant: 10),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            progressSlider.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 10),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            playButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 20),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 120),
            playButton.heightAnchor.constraint(equalToConstant: 50),

            fillerWordsCountLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 30),
            fillerWordsCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fillerWordsCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            wpmLabel.topAnchor.constraint(equalTo: fillerWordsCountLabel.bottomAnchor, constant: 5),
            wpmLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wpmLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            fillerWordsListView.topAnchor.constraint(equalTo: wpmLabel.bottomAnchor, constant: 15),
            fillerWordsListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            fillerWordsListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            fillerWordsListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupAudioManager() {
        audioPlaybackManager.delegate = self
    }

    private func loadAudio() {
        do {
            try audioPlaybackManager.loadAudio(from: recording.audioFileURL)
        } catch {
            showError("Failed to load audio: \(error.localizedDescription)")
        }
    }

    private func updateFillerWordsDisplay() {
        if let analysis = recording.analysisResults {
            fillerWordsCountLabel.text = "Filler Words Detected: \(analysis.totalFillerWords)"

            if let wpm = analysis.wordsPerMinute {
                wpmLabel.text = String(format: "Words Per Minute: %.1f", wpm)
            }

            if analysis.fillerWords.isEmpty {
                fillerWordsListView.text = "No filler words detected. Great job!"
            } else {
                var listText = ""
                for fillerWord in analysis.fillerWords {
                    let timestamp = formatTime(fillerWord.timestamp)
                    listText += "\(timestamp) - \"\(fillerWord.word)\"\n"
                }
                fillerWordsListView.text = listText
            }
        } else {
            fillerWordsCountLabel.text = "Analysis not available"
            fillerWordsListView.text = "Audio analysis was not performed for this recording."
        }
    }

    @objc private func playButtonTapped() {
        if audioPlaybackManager.isPlaying {
            audioPlaybackManager.pause()
            playButton.setTitle("Play", for: .normal)
        } else {
            audioPlaybackManager.play()
            playButton.setTitle("Pause", for: .normal)
        }
    }

    @objc private func sliderValueChanged() {
        audioPlaybackManager.seek(to: TimeInterval(progressSlider.value))
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PlaybackViewController: AudioPlaybackManagerDelegate {
    func audioPlaybackManager(_ manager: AudioPlaybackManager, didUpdateTime time: TimeInterval) {
        currentTimeLabel.text = formatTime(time)
        remainingTimeLabel.text = formatTime(recording.duration - time)
        progressSlider.value = Float(time)
        timelineView.updateCurrentTime(time)
    }

    func audioPlaybackManagerDidFinishPlaying(_ manager: AudioPlaybackManager) {
        playButton.setTitle("Play", for: .normal)
        progressSlider.value = 0
        currentTimeLabel.text = "00:00"
        remainingTimeLabel.text = formatTime(recording.duration)
        timelineView.updateCurrentTime(0)
    }

    func audioPlaybackManager(_ manager: AudioPlaybackManager, didFailWithError error: Error) {
        showError("Playback error: \(error.localizedDescription)")
    }
}
