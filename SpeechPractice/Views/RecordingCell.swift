import UIKit

class RecordingCell: UITableViewCell {
    static let identifier = "RecordingCell"

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    private let fillerWordsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        contentView.addSubview(titleLabel)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        contentView.addSubview(dateLabel)

        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        durationLabel.textColor = .secondaryLabel
        contentView.addSubview(durationLabel)

        fillerWordsLabel.translatesAutoresizingMaskIntoConstraints = false
        fillerWordsLabel.font = .systemFont(ofSize: 12, weight: .regular)
        fillerWordsLabel.textColor = .systemOrange
        contentView.addSubview(fillerWordsLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            durationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            fillerWordsLabel.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),
            fillerWordsLabel.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 12)
        ])
    }

    func configure(with recording: Recording) {
        titleLabel.text = recording.title
        dateLabel.text = DateFormatter.localizedString(from: recording.date, dateStyle: .medium, timeStyle: .short)

        let minutes = Int(recording.duration) / 60
        let seconds = Int(recording.duration) % 60
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)

        if let analysis = recording.analysisResults {
            fillerWordsLabel.text = "Filler words: \(analysis.totalFillerWords)"
        } else {
            fillerWordsLabel.text = ""
        }
    }
}
