import Foundation

struct RecordingAnalysis: Codable {
    let totalFillerWords: Int
    let fillerWords: [FillerWord]
    let analyzedDate: Date
    let wordsPerMinute: Double?

    init(totalFillerWords: Int, fillerWords: [FillerWord], analyzedDate: Date = Date(), wordsPerMinute: Double? = nil) {
        self.totalFillerWords = totalFillerWords
        self.fillerWords = fillerWords
        self.analyzedDate = analyzedDate
        self.wordsPerMinute = wordsPerMinute
    }
}
