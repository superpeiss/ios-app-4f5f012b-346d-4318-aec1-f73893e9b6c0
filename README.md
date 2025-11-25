# Speech Practice iOS App

A production-ready iOS application that helps students improve their public speaking skills through objective feedback.

## Features

- **Audio Recording**: Record timed speeches with a built-in timer
- **On-Device Filler Word Detection**: Automatically detects common filler words like "um", "uh", "ah", etc.
- **Visual Playback**: Playback interface with timeline visualization showing where filler words occurred
- **Local Storage**: All recordings and analysis results are saved locally on the device
- **Progress Tracking**: Track improvement over time with detailed statistics
- **MVC Architecture**: Clean, maintainable codebase following Model-View-Controller design pattern

## Technical Details

- **Platform**: iOS 15.0+
- **Language**: Swift 5.9
- **Architecture**: MVC (Model-View-Controller)
- **UI Framework**: UIKit
- **Audio Processing**: AVFoundation
- **Speech Recognition**: Speech Framework (on-device)
- **Project Generation**: XcodeGen

## Requirements

- Xcode 15.0+
- iOS 15.0+
- XcodeGen (for project generation)

## Setup

1. Install XcodeGen:
```bash
brew install xcodegen
```

2. Generate Xcode project:
```bash
xcodegen generate
```

3. Open the generated project:
```bash
open SpeechPractice.xcodeproj
```

4. Build and run on your device or simulator

## Privacy

This app requires the following permissions:
- **Microphone Access**: Required to record audio
- **Speech Recognition**: Required for on-device filler word analysis

All processing is done locally on the device. No data is sent to external servers.

## Project Structure

```
SpeechPractice/
├── Models/              # Data models
│   ├── Recording.swift
│   ├── RecordingAnalysis.swift
│   └── FillerWord.swift
├── Views/               # UI Views
│   ├── RecordingCell.swift
│   └── TimelineView.swift
├── Controllers/         # View Controllers
│   ├── RecordingsListViewController.swift
│   ├── RecordingViewController.swift
│   └── PlaybackViewController.swift
├── Services/            # Business Logic
│   ├── AudioRecordingManager.swift
│   ├── AudioPlaybackManager.swift
│   ├── FillerWordDetector.swift
│   └── StorageManager.swift
└── Resources/           # Assets and resources
```

## License

MIT License
