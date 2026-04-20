# Earthling Root

A simple offline-first habit and land stewardship tracker app built with Flutter.

## Features

- 📋 **Daily Task Checklist**: Track 6 daily stewardship tasks
- 🎯 **Points System**: Earn points by completing tasks
- 📊 **Level System**: Level up as you accumulate 100 points
- 🔄 **Reset Function**: Reset all tasks and points at the end of the day
- 🎨 **Simple UI**: Clean, minimal material design interface
- 📱 **Offline-First**: Works completely offline, no backend required

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Android SDK (for Android development)
- Or Xcode (for iOS development)

### Installation

1. Navigate to the project directory:
```bash
cd earthling_root
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run on emulator or device:
```bash
flutter run
```

### Building

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle
```

**iOS:**
```bash
flutter build ios
```

## Project Structure

```
earthling_root/
├── lib/
│   └── main.dart          # Main app implementation
├── android/               # Android configuration
├── ios/                   # iOS configuration
├── pubspec.yaml           # Flutter project configuration
└── README.md              # This file
```

## Tasks Included

- Check chickens (10 pts)
- Water plants (10 pts)
- Walk the land (5 pts)
- Deep work build (20 pts)
- Learn / study (10 pts)
- Reflection (5 pts)

## Design

The app features:

- **Daily Theme**: Displays a different theme for each day of the week
- **Points Display**: Shows total points earned for the day
- **Level System**: Level = totalPoints / 100 (integer division)
- **Task Toggles**: Click checkboxes to mark tasks complete
- **Reset Button**: Resets all tasks and points for a new day

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **UI**: Material Design
- **Storage**: In-memory (stateful) - persists during app session only

## Future Enhancements

- Local storage with SQLite
- Persistent data across app sessions
- More detailed analytics
- Customizable tasks
- Different themes and customization
- Integration with land stewardship partner systems

## Notes

This is a v0.1 prototype seed system designed for evolution into a decentralized Earthling system. The code is intentionally simple and readable to facilitate future extensions.
