import Foundation

struct Recording: Codable {
    let id: UUID
    let title: String
    let date: Date
    let duration: TimeInterval
    let audioFileURL: URL
    let analysisResults: RecordingAnalysis?

    init(id: UUID = UUID(), title: String, date: Date = Date(), duration: TimeInterval, audioFileURL: URL, analysisResults: RecordingAnalysis? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.duration = duration
        self.audioFileURL = audioFileURL
        self.analysisResults = analysisResults
    }

    func withAnalysis(_ analysis: RecordingAnalysis) -> Recording {
        return Recording(
            id: self.id,
            title: self.title,
            date: self.date,
            duration: self.duration,
            audioFileURL: self.audioFileURL,
            analysisResults: analysis
        )
    }
}
