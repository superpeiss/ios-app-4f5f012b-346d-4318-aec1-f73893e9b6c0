import UIKit

class TimelineView: UIView {
    private var duration: TimeInterval = 0
    private var fillerWords: [FillerWord] = []
    private var currentTime: TimeInterval = 0

    private let progressView = UIView()
    private let markerViews: NSMutableArray = NSMutableArray()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        progressView.backgroundColor = .systemBlue
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0)
        ])
    }

    func configure(duration: TimeInterval, fillerWords: [FillerWord]) {
        self.duration = duration
        self.fillerWords = fillerWords
        layoutIfNeeded()
        drawFillerWordMarkers()
    }

    private func drawFillerWordMarkers() {
        // Remove old markers
        for view in markerViews {
            (view as? UIView)?.removeFromSuperview()
        }
        markerViews.removeAllObjects()

        guard duration > 0 else { return }

        for fillerWord in fillerWords {
            let markerView = UIView()
            markerView.backgroundColor = .systemRed
            markerView.layer.cornerRadius = 3
            markerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(markerView)

            let position = CGFloat(fillerWord.timestamp / duration)

            NSLayoutConstraint.activate([
                markerView.centerYAnchor.constraint(equalTo: centerYAnchor),
                markerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: position * bounds.width),
                markerView.widthAnchor.constraint(equalToConstant: 6),
                markerView.heightAnchor.constraint(equalToConstant: 40)
            ])

            markerViews.add(markerView)
        }
    }

    func updateCurrentTime(_ time: TimeInterval) {
        currentTime = time
        guard duration > 0 else { return }

        let progress = CGFloat(min(time / duration, 1.0))

        // Update progress view width
        progressView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width {
                constraint.isActive = false
            }
        }

        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: progress)
        ])

        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawFillerWordMarkers()
    }
}
