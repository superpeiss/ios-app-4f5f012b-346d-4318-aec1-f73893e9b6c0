import Foundation

struct FillerWord: Codable {
    let word: String
    let timestamp: TimeInterval
    let duration: TimeInterval

    init(word: String, timestamp: TimeInterval, duration: TimeInterval) {
        self.word = word
        self.timestamp = timestamp
        self.duration = duration
    }
}
