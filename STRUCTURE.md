# TaskFlow Pro - Struktur Aplikasi

Aplikasi Task Management canggih dengan fitur produktivitas lengkap.

## 📁 Struktur Folder

```
lib/
├── main.dart                    # Entry point aplikasi
├── core/                       # Core functionality
│   ├── constants/
│   │   └── app_constants.dart  # Konstanta global
│   ├── theme/
│   │   ├── app_theme.dart      # Light & Dark theme
│   │   └── theme_provider.dart # Theme state management (Riverpod)
│   └── router/
│       └── app_router.dart      # GoRouter configuration
│
├── models/                     # Data models
│   └── task_category.dart      # Model kategori tugas
│
├── data/                       # Data layer
│   └── datasources/
│       └── local/
│           └── database.dart   # Drift database (local, akan diganti Firebase)
│
├── features/                   # Feature modules
│   ├── home/                   # Home page - Today's tasks
│   │   └── home_page.dart
│   │
│   ├── tasks/                  # Task management
│   │   └── bloc/
│   │       └── task_bloc.dart  # Task BLoC (state management)
│   │
│   ├── timer/                  # Pomodoro Timer
│   │   ├── bloc/
│   │   │   └── pomodoro_bloc.dart
│   │   └── pomodoro_timer_page.dart
│   │
│   ├── voice/                  # Voice Commands
│   │   ├── bloc/
│   │   │   └── voice_bloc.dart
│   │   └── voice_command_page.dart
│   │
│   ├── calendar/               # Calendar View
│   │   └── calendar_page.dart
│   │
│   ├── projects/               # Projects Management
│   │   └── projects_page.dart
│   │
│   ├── categories/             # Category Management
│   │   └── categories_page.dart
│   │
│   ├── templates/              # Project Templates
│   │   └── project_templates_page.dart
│   │
│   ├── task_dependencies/      # Task Dependencies
│   │   └── task_dependencies_page.dart
│   │
│   ├── analytics/              # Statistics & Analytics
│   │   └── analytics_page.dart
│   │
│   └── settings/               # App Settings
│       └── settings_page.dart
│
├── shared/                     # Shared widgets
│   └── widgets/
│       └── task_card.dart      # Reusable task card widget
│
└── services/                   # Services (akan ditambah)
    ├── auth_service.dart      # Firebase Auth service
    └── database_service.dart  # Firestore service
```

## 🏗️ Arsitektur

### State Management
- **BLoC Pattern** (`flutter_bloc`) - untuk Task, Pomodoro, Voice
- **Riverpod** - untuk Theme & Auth state

### Navigation
- **GoRouter** - Declarative routing dengan deep linking

### Database (Sementara - Akan diganti Firebase)
- **Drift** (SQLite) - Local database storage

### Database (Target - Firebase)
- **Cloud Firestore** - NoSQL cloud database
- **Firebase Auth** - Email/Password & Google Sign-In

## 📱 Fitur Aplikasi

### 1. Home Page
- Salam berdasarkan waktu (Pagi/Siang/Sore/Malam)
- Statistik hari ini (Selesai, Pending, Fokus)
- Filter kategori tugas
- Quick actions menu (Add Task, Timer, Voice, Template, Kategori)

### 2. Task Management
- Create task dengan kategori
- Set priority (P1-P4)
- Edit/Delete task
- Mark task as completed

### 3. Kategori Tugas
- 14 kategori bawaan:
  - 💼 Pekerjaan, 👤 Pribadi, 🛒 Belanja, 🏥 Kesehatan
  - ⚽ Olahraga, 📚 Belajar, 🎬 Film, 🎵 Musik
  - ✈️ Travel, 💰 Keuangan, 🍽️ Makanan, 🎮 Gaming
  - 👥 Sosial, 🔧 DIY
- Buat kategori custom dengan icon & warna
- Edit/hapus kategori custom

### 4. Pomodoro Timer
- Timer fokus 25 menit
- Istirahat pendek 5 menit
- Istirahat panjang 15 menit
- Notifikasi audio & visual

### 5. Voice Commands
- Tambah tugas dengan suara
- Bahasa Indonesia
- Speech-to-text integration

### 6. Calendar View
- Kalender bulanan
- Tugas per tanggal
- Navigate antar bulan

### 7. Project Management
- List proyek dengan progress
- Template proyek
- Ketergantungan tugas

### 8. Analytics
- Statistik produktivitas
- Chart progress
- Ringkasan performa

### 9. Settings
- Theme switcher (Light/Dark/System)
- Notifikasi settings
- Pomodoro configuration
- Data backup/restore

## 🔧 Flow Aplikasi

### Flow User Baru:
1. **Splash Screen** → **Login/Register** (Firebase Auth)
2. Setelah login → **Home Page** (Dashboard)
3. User bisa:
   - Add task dengan kategori
   - Lihat calendar
   - Gunakan Pomodoro timer
   - Atur proyek dan kategori
   - Lihat statistik

### Data Flow:
```
User Action → BLoC Event → BLoC State Update → UI Refresh
           ↓
     Service/Repository → Firebase Firestore → Cloud
```

## 🎯 Status Fitur

| Fitur | Status | Catatan |
|-------|--------|---------|
| Home Page | ✅ Ready | Dengan filter kategori |
| Kategori | ✅ Ready | 14 kategori + custom |
| Task CRUD | ⚠️ Perbaiki | Belum connect ke database |
| Pomodoro Timer | ✅ Ready | Dengan audio notification |
| Voice Commands | ✅ Ready | Speech-to-text Indonesia |
| Calendar | ✅ Ready | Table calendar integration |
| Projects | ⚠️ Perbaiki | Perbaiki SliverGrid error |
| Templates | ✅ Ready | Predefined templates |
| Dependencies | ✅ Ready | Task dependencies visualization |
| Analytics | ✅ Ready | Charts & statistics |
| Settings | ⚠️ Perbaiki | Dark mode perlu Riverpod fix |
| Auth | ❌ Todo | Firebase Auth integration |
| Database | ❌ Todo | Firebase Firestore integration |
| Android Build | ⚠️ Testing | Windows ready, Android perlu test |

## 🚀 Langkah Selanjutnya

1. ✅ Perbaiki semua error yang ada
2. ✅ Implementasi Firebase Auth
3. ✅ Implementasi Firestore untuk task data
4. ✅ Android configuration & testing
5. ✅ Final testing semua fitur
6. ✅ Prepare Play Store assets

## 📝 Catatan Development

- **Target Platform**: Android (Play Store)
- **Framework**: Flutter 3.x
- **State Management**: BLoC + Riverpod
- **Backend**: Firebase (Auth + Firestore)
- **Language**: Dart (Flutter)

---

*Last Updated: 7 Maret 2026*
