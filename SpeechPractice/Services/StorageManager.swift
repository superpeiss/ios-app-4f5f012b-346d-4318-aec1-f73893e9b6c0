import Foundation

class StorageManager {
    static let shared = StorageManager()

    private let recordingsKey = "recordings"
    private let fileManager = FileManager.default

    private init() {
        createDirectoriesIfNeeded()
    }

    private func createDirectoriesIfNeeded() {
        let recordingsDirectory = getRecordingsDirectory()
        if !fileManager.fileExists(atPath: recordingsDirectory.path) {
            try? fileManager.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
        }
    }

    private func getRecordingsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Recordings")
    }

    private func getMetadataFileURL() -> URL {
        getRecordingsDirectory().appendingPathComponent("recordings_metadata.json")
    }

    // MARK: - Save Recording

    func saveRecording(_ recording: Recording) throws {
        var recordings = try loadAllRecordings()

        // Remove existing recording with same ID if it exists
        recordings.removeAll { $0.id == recording.id }

        // Add new recording
        recordings.append(recording)

        // Save to file
        try saveRecordings(recordings)
    }

    private func saveRecordings(_ recordings: [Recording]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(recordings)
        try data.write(to: getMetadataFileURL())
    }

    // MARK: - Load Recordings

    func loadAllRecordings() throws -> [Recording] {
        let metadataURL = getMetadataFileURL()

        guard fileManager.fileExists(atPath: metadataURL.path) else {
            return []
        }

        let data = try Data(contentsOf: metadataURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let recordings = try decoder.decode([Recording].self, from: data)

        // Filter out recordings whose audio files no longer exist
        return recordings.filter { fileManager.fileExists(atPath: $0.audioFileURL.path) }
    }

    // MARK: - Delete Recording

    func deleteRecording(_ recording: Recording) throws {
        var recordings = try loadAllRecordings()
        recordings.removeAll { $0.id == recording.id }
        try saveRecordings(recordings)

        // Delete audio file
        if fileManager.fileExists(atPath: recording.audioFileURL.path) {
            try fileManager.removeItem(at: recording.audioFileURL)
        }
    }

    // MARK: - Update Recording

    func updateRecording(_ recording: Recording) throws {
        var recordings = try loadAllRecordings()

        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
            try saveRecordings(recordings)
        }
    }
}
