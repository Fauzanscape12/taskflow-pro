import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'TaskFlow Pro';
  static const String appVersion = '1.0.0';

  // Brand Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Violet
  static const Color accentColor = Color(0xFFF43F5E); // Rose
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color infoColor = Color(0xFF3B82F6); // Blue

  // Priority Colors
  static const Color priority1Color = Color(0xFFEF4444); // Red - Urgent
  static const Color priority2Color = Color(0xFFF97316); // Orange - High
  static const Color priority3Color = Color(0xFFEAB308); // Yellow - Normal
  static const Color priority4Color = Color(0xFF6B7280); // Gray - Low

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
  ];

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pomodoro Settings
  static const int pomodoroWorkMinutes = 25;
  static const int pomodoroShortBreakMinutes = 5;
  static const int pomodoroLongBreakMinutes = 15;
  static const int pomodoroSessionsBeforeLongBreak = 4;

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';

  // Storage Keys
  static const String keyOnboarding = 'onboarding_completed';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstRun = 'first_run';
  static const String keyUserId = 'user_id';

  // Natural Language Patterns (Indonesian)
  static const Map<String, String> nlPatterns = {
    'besok': 'tomorrow',
    'lusa': 'day after tomorrow',
    'hari ini': 'today',
    'minggu ini': 'this week',
    'bulan depan': 'next month',
    'setiap hari': 'every day',
    'setiap minggu': 'every week',
    'setiap bulan': 'every month',
    'pagi': 'morning',
    'siang': 'afternoon',
    'sore': 'evening',
    'malam': 'night',
    'p1': 'priority 1',
    'p2': 'priority 2',
    'p3': 'priority 3',
    'p4': 'priority 4',
  };

  // AI Prompts
  static const String aiSystemPrompt = '''
    Anda adalah asisten produktivitas yang membantu pengguna mengelola tugas.
    Jawab dalam Bahasa Indonesia dengan singkat, jelas, dan actionable.
  ''';
}

/// Priority Levels
enum Priority {
  p1, // Urgent & Important
  p2, // Important & Not Urgent
  p3, // Not Important & Urgent
  p4, // Not Important & Not Urgent
}

/// Task Status
enum TaskStatus {
  todo,
  inProgress,
  completed,
  cancelled,
}

/// Task Duration (for time estimation)
enum TaskDuration {
  none,
  minutes15,
  minutes30,
  hours1,
  hours2,
  hours4,
  hours8,
}
