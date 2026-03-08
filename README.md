# TaskFlow Pro

Advanced Task Management App - More powerful than Todoist!

## Features

- ✅ Smart Task Management with Natural Language Processing
- 📅 Integrated Calendar with Time Blocking
- 🎯 Project Organization with Kanban View
- ⏱️ Built-in Pomodoro Timer
- 📊 Productivity Analytics
- 🎤 Voice Commands & Notes
- 🤖 AI-Powered Task Scheduling
- 🌙 Beautiful Dark Mode
- 📱 Material Design 3

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

1. Clone this repository
2. Run `flutter pub get`
3. Run `flutter run`

## Project Structure

```
lib/
├── core/
│   ├── constants/     # App-wide constants
│   ├── theme/         # App theme configuration
│   ├── router/        # Navigation routes
│   └── utils/         # Utility functions
├── features/
│   ├── auth/          # Authentication
│   ├── home/          # Home / Today view
│   ├── calendar/      # Calendar view
│   ├── projects/      # Projects management
│   ├── tasks/         # Task management
│   ├── timer/         # Pomodoro timer
│   ├── analytics/     # Productivity analytics
│   └── settings/      # App settings
├── data/
│   ├── models/        # Data models
│   ├── repositories/  # Repository pattern
│   └── datasources/   # Local & remote data sources
└── shared/
    └── widgets/       # Reusable widgets
```

## Tech Stack

- **State Management**: Flutter Bloc
- **Database**: Drift (SQLite)
- **Navigation**: GoRouter
- **Animations**: Flutter Animate
- **Charts**: FL Chart

## License

MIT License
