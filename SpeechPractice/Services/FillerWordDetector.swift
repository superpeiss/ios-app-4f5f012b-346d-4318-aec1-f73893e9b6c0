import Foundation
import Speech

class FillerWordDetector {
    private let fillerWordPatterns = ["um", "uh", "ah", "er", "like", "you know", "so", "basically", "actually"]

    func analyzeAudio(at url: URL, completion: @escaping (Result<RecordingAnalysis, Error>) -> Void) {
        // Request speech recognition authorization
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                completion(.failure(NSError(domain: "FillerWordDetector", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized"])))
                return
            }

            self.performAnalysis(at: url, completion: completion)
        }
    }

    private func performAnalysis(at url: URL, completion: @escaping (Result<RecordingAnalysis, Error>) -> Void) {
        guard let recognizer = SFSpeechRecognizer() else {
            completion(.failure(NSError(domain: "FillerWordDetector", code: 2, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available"])))
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        request.taskHint = .dictation

        recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let result = result, result.isFinal else {
                return
            }

            let fillerWords = self.detectFillerWords(in: result)
            let wordCount = result.bestTranscription.segments.count
            let duration = result.bestTranscription.segments.last?.timestamp ?? 0
            let wordsPerMinute = duration > 0 ? (Double(wordCount) / duration) * 60.0 : 0

            let analysis = RecordingAnalysis(
                totalFillerWords: fillerWords.count,
                fillerWords: fillerWords,
                wordsPerMinute: wordsPerMinute
            )

            completion(.success(analysis))
        }
    }

    private func detectFillerWords(in result: SFSpeechRecognitionResult) -> [FillerWord] {
        var detectedFillerWords: [FillerWord] = []
        let transcription = result.bestTranscription

        for segment in transcription.segments {
            let word = segment.substring.lowercased()

            // Check if the word or phrase matches filler patterns
            if fillerWordPatterns.contains(where: { pattern in
                word.contains(pattern) || word == pattern
            }) {
                let fillerWord = FillerWord(
                    word: segment.substring,
                    timestamp: segment.timestamp,
                    duration: segment.duration
                )
                detectedFillerWords.append(fillerWord)
            }
        }

        // Also check for multi-word patterns
        for i in 0..<transcription.segments.count - 1 {
            let twoWordPhrase = "\(transcription.segments[i].substring) \(transcription.segments[i+1].substring)".lowercased()

            if fillerWordPatterns.contains(twoWordPhrase) {
                let fillerWord = FillerWord(
                    word: twoWordPhrase,
                    timestamp: transcription.segments[i].timestamp,
                    duration: transcription.segments[i].duration + transcription.segments[i+1].duration
                )
                detectedFillerWords.append(fillerWord)
            }
        }

        return detectedFillerWords
    }
}
