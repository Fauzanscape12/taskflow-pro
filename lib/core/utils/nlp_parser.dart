import 'package:intl/intl.dart';
import 'package:drift/drift.dart';

import '../constants/app_constants.dart';
import '../../data/datasources/local/database.dart';

/// Natural Language Parser for Quick Task Add
/// Supports Indonesian and English
class NLPParser {
  NLPParser._();

  /// Parse natural language text into structured task data
  static ParsedTask parse(String text) {
    final lowerText = text.toLowerCase().trim();

    // Extract all data first
    final title = _extractTitle(lowerText);
    final priority = _extractPriority(lowerText);
    final dueDate = _extractDate(lowerText);
    final dueTime = _extractTime(lowerText);
    final labels = _extractLabels(lowerText);
    final projectName = _extractProjectName(lowerText);
    final recurring = _extractRecurring(lowerText);
    final estimatedMinutes = _extractTimeEstimate(lowerText);

    return ParsedTask(
      title: title,
      priority: priority,
      dueDate: dueDate,
      dueTime: dueTime,
      labels: labels,
      projectName: projectName,
      recurring: recurring,
      estimatedMinutes: estimatedMinutes,
    );
  }

  static String _extractTitle(String text) {
    // Remove all keywords and special patterns
    var result = text;

    // Remove time patterns
    result = result.replaceAll(RegExp(r'\d{1,2}:\d{2}'), '');
    result = result.replaceAll(RegExp(r'jam\s*\d{1,2}'), '');
    result = result.replaceAll(RegExp(r'pk\d{2}'), '');

    // Remove date patterns
    final dateKeywords = [
      'hari ini',
      'besok',
      'lusa',
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu',
      'today',
      'tomorrow',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    for (final keyword in dateKeywords) {
      result = result.replaceAll(keyword, '');
    }

    // Remove priority keywords
    final priorityKeywords = [
      'p1',
      'p2',
      'p3',
      'p4',
      'prioritas 1',
      'prioritas 2',
      'prioritas 3',
      'prioritas 4',
      'priority 1',
      'priority 2',
      'priority 3',
      'priority 4',
      'penting',
      'urgent',
      'tinggi',
      'rendah',
    ];

    for (final keyword in priorityKeywords) {
      result = result.replaceAll(keyword, '');
    }

    // Remove recurring keywords
    final recurringKeywords = [
      'setiap',
      'tiap',
      'every',
      'harian',
      'mingguan',
      'bulanan',
      'daily',
      'weekly',
      'monthly',
    ];

    for (final keyword in recurringKeywords) {
      result = result.replaceAll(keyword, '');
    }

    // Remove project indicators
    result = result.replaceAll(RegExp(r'(?:proyek|project|proj|p)[\s:]*[a-zA-Z]+'), '');
    result = result.replaceAll(RegExp(r'#[a-zA-Z]+'), '');
    result = result.replaceAll(RegExp(r'@[a-zA-Z]+'), '');

    // Remove label indicators
    result = result.replaceAll(RegExp(r'label[\s:]*[a-zA-Z]+'), '');
    result = result.replaceAll(RegExp(r'tag[\s:]*[a-zA-Z]+'), '');

    // Remove special characters
    result = result.replaceAll(RegExp(r'[^\w\s]'), '');

    // Clean up spaces
    result = result.trim();
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    // Capitalize first letter
    if (result.isEmpty) {
      return 'Tugas Baru';
    }

    return result[0].toUpperCase() + result.substring(1);
  }

  static int _extractPriority(String text) {
    // Direct priority indicators
    if (text.contains('p1') || text.contains('!3') || text.contains('!!!')) {
      return 1;
    } else if (text.contains('p2') || text.contains('!2') || text.contains('!!')) {
      return 2;
    } else if (text.contains('p3') || text.contains('!1') || text.contains('!')) {
      return 3;
    } else if (text.contains('p4')) {
      return 4;
    }

    // Word-based priority (Indonesian)
    if (text.contains(' sangat penting') ||
        text.contains('urgent') ||
        text.contains('darurat') ||
        text.contains('kritis')) {
      return 1;
    } else if (text.contains('penting') ||
        text.contains('tinggi') ||
        text.contains('high')) {
      return 2;
    } else if (text.contains('rendah') ||
        text.contains('low') ||
        text.contains('santai')) {
      return 4;
    }

    return 3; // Default
  }

  static DateTime? _extractDate(String text) {
    final now = DateTime.now();

    // Today
    if (text.contains('hari ini') || text.contains('today')) {
      return now;
    }

    // Tomorrow
    if (text.contains('besok') || text.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    }

    // Day after tomorrow
    if (text.contains('lusa')) {
      return now.add(const Duration(days: 2));
    }

    // Next [weekday]
    final weekdayMap = {
      'senin': DateTime.monday,
      'selasa': DateTime.tuesday,
      'rabu': DateTime.wednesday,
      'kamis': DateTime.thursday,
      'jumat': DateTime.friday,
      'sabtu': DateTime.saturday,
      'minggu': DateTime.sunday,
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    for (final entry in weekdayMap.entries) {
      if (text.contains(entry.key)) {
        return _getNextWeekday(now, entry.value);
      }
    }

    // "Next week" patterns
    if (text.contains('minggu depan') || text.contains('next week')) {
      return now.add(const Duration(days: 7));
    }

    // "In [x] days"
    final daysMatch = RegExp(r'(\d+)\s*hari lagi').firstMatch(text);
    if (daysMatch != null) {
      final days = int.parse(daysMatch.group(1)!);
      return now.add(Duration(days: days));
    }

    return null;
  }

  static DateTime _getNextWeekday(DateTime date, int weekday) {
    final currentWeekday = date.weekday == DateTime.sunday ? 7 : date.weekday;
    final daysUntil = (weekday - currentWeekday + 7) % 7;
    return date.add(Duration(days: daysUntil == 0 ? 7 : daysUntil));
  }

  static String? _extractTime(String text) {
    // Time keywords (Indonesian)
    final timeKeywords = {
      'pagi': '09:00',
      'subuh': '04:30',
      'dini hari': '06:00',
      'siang': '13:00',
      'tengah hari': '12:00',
      'sore': '15:00',
      'petang': '16:00',
      'malam': '19:00',
      'tengah malam': '23:00',
    };

    for (final entry in timeKeywords.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    // Extract "jam/pk X" pattern (Indonesian format)
    final timeMatch = RegExp(r'(?:jam|pk|\.|\s)\s*(\d{1,2})').firstMatch(text);
    if (timeMatch != null) {
      final hour = int.parse(timeMatch.group(1)!);
      if (hour >= 0 && hour <= 23) {
        return '${hour.toString().padLeft(2, '0')}:00';
      }
    }

    // Extract "X:Y" pattern (HH:MM format)
    final exactMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(text);
    if (exactMatch != null) {
      final hour = int.parse(exactMatch.group(1)!);
      final minute = int.parse(exactMatch.group(2)!);
      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }

    return null;
  }

  static List<String> _extractLabels(String text) {
    final labels = <String>[];

    // Extract #label pattern
    final hashTags = RegExp(r'#(\w+)').allMatches(text);
    for (final match in hashTags) {
      labels.add(match.group(1)!);
    }

    // Extract @label pattern
    final atTags = RegExp(r'@(\w+)').allMatches(text);
    for (final match in atTags) {
      labels.add(match.group(1)!);
    }

    // Extract "label: X" pattern
    final labelMatches = RegExp(r'label[:\s]+(\w+)').allMatches(text);
    for (final match in labelMatches) {
      labels.add(match.group(1)!);
    }

    // Common label keywords
    if (text.contains('kerja')) labels.add('kerja');
    if (text.contains('pribadi')) labels.add('pribadi');
    if (text.contains('belajar')) labels.add('belajar');
    if (text.contains('kesehatan')) labels.add('kesehatan');
    if (text.contains('rumah')) labels.add('rumah');

    return labels.toSet().toList();
  }

  static String? _extractProjectName(String text) {
    // Pattern: "project X" or "proyek X"
    final projMatch = RegExp(r'(?:proyek|project)[\s:]+([a-zA-Z0-9\s]+)')
        .firstMatch(text);
    if (projMatch != null) {
      return projMatch.group(1)!.trim();
    }

    return null;
  }

  static RecurringPattern? _extractRecurring(String text) {
    // Daily patterns
    if (text.contains('setiap hari') || text.contains('harian') || text.contains('daily')) {
      return RecurringPattern.daily;
    }

    // Weekly patterns
    if (text.contains('setiap minggu') || text.contains('mingguan') || text.contains('weekly')) {
      return RecurringPattern.weekly;
    }

    // Monthly patterns
    if (text.contains('setiap bulan') || text.contains('bulanan') || text.contains('monthly')) {
      return RecurringPattern.monthly;
    }

    // Weekday patterns
    if (text.contains('setiap senin') || text.contains('setiap monday')) {
      return RecurringPattern.weeklyOnMonday;
    }
    if (text.contains('setiap selasa') || text.contains('setiap tuesday')) {
      return RecurringPattern.weeklyOnTuesday;
    }
    if (text.contains('setiap rabu') || text.contains('setiap wednesday')) {
      return RecurringPattern.weeklyOnWednesday;
    }
    if (text.contains('setiap kamis') || text.contains('setiap thursday')) {
      return RecurringPattern.weeklyOnThursday;
    }
    if (text.contains('setiap jumat') || text.contains('setiap friday')) {
      return RecurringPattern.weeklyOnFriday;
    }

    return null;
  }

  static int? _extractTimeEstimate(String text) {
    // Extract "X jam" pattern
    final hourMatch = RegExp(r'(\d+)\s*jam').firstMatch(text);
    if (hourMatch != null) {
      final hours = int.parse(hourMatch.group(1)!);
      return hours * 60;
    }

    // Extract "X menit" pattern
    final minMatch = RegExp(r'(\d+)\s*menit').firstMatch(text);
    if (minMatch != null) {
      return int.parse(minMatch.group(1)!);
    }

    return null;
  }

  /// Format parsed task into human-readable summary
  static String formatSummary(ParsedTask task) {
    final buffer = StringBuffer();
    buffer.write('📝 ${task.title}');

    if (task.dueDate != null || task.dueTime != null) {
      buffer.write('\n📅 ');
      if (task.dueDate != null) {
        buffer.write(_formatDate(task.dueDate!));
        if (task.dueTime != null) {
          buffer.write(' jam ${task.dueTime}');
        }
      } else if (task.dueTime != null) {
        buffer.write('jam ${task.dueTime}');
      }
    }

    if (task.priority != 3) {
      buffer.write('\n⚡ Priority: P${task.priority}');
    }

    if (task.labels.isNotEmpty) {
      buffer.write('\n🏷️ ${task.labels.join(', ')}');
    }

    if (task.projectName != null) {
      buffer.write('\n📁 Project: ${task.projectName}');
    }

    if (task.recurring != null) {
      buffer.write('\� Recurring: ${_formatRecurring(task.recurring!)}');
    }

    if (task.estimatedMinutes != null) {
      final hours = task.estimatedMinutes! ~/ 60;
      final mins = task.estimatedMinutes! % 60;
      buffer.write('\n⏱️ Estimasi: ');
      if (hours > 0) {
        buffer.write('$hours jam ');
      }
      buffer.write('$mins menit');
    }

    return buffer.toString();
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Hari ini';
    }

    final tomorrow = today.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Besok';
    }

    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String _formatRecurring(RecurringPattern pattern) {
    switch (pattern) {
      case RecurringPattern.daily:
        return 'Setiap hari';
      case RecurringPattern.weekly:
        return 'Setiap minggu';
      case RecurringPattern.monthly:
        return 'Setiap bulan';
      case RecurringPattern.weeklyOnMonday:
        return 'Setiap senin';
      case RecurringPattern.weeklyOnTuesday:
        return 'Setiap selasa';
      case RecurringPattern.weeklyOnWednesday:
        return 'Setiap rabu';
      case RecurringPattern.weeklyOnThursday:
        return 'Setiap kamis';
      case RecurringPattern.weeklyOnFriday:
        return 'Setiap jumat';
      case RecurringPattern.weeklyOnSaturday:
        return 'Setiap sabtu';
      case RecurringPattern.weeklyOnSunday:
        return 'Setiap minggu';
    }
  }
}

/// Parsed Task Result
class ParsedTask {
  final String title;
  final int priority;
  final DateTime? dueDate;
  final String? dueTime;
  final List<String> labels;
  final String? projectName;
  final RecurringPattern? recurring;
  final int? estimatedMinutes;

  ParsedTask({
    required this.title,
    required this.priority,
    this.dueDate,
    this.dueTime,
    this.labels = const [],
    this.projectName,
    this.recurring,
    this.estimatedMinutes,
  });

  /// Get combined due date time
  DateTime? get dueDateTime {
    if (dueDate == null) return null;

    if (dueTime != null) {
      final parts = dueTime!.split(':');
      return DateTime(
        dueDate!.year,
        dueDate!.month,
        dueDate!.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    return dueDate;
  }

  /// Convert to TasksCompanion for database
  TasksCompanion toTasksCompanion() {
    return TasksCompanion(
      title: Value(title),
      priority: Value(priority),
      dueDate: dueDateTime != null ? Value(dueDateTime!) : const Value.absent(),
      labels: labels.isNotEmpty ? Value(labels.join(',')) : const Value.absent(),
      estimatedMinutes: estimatedMinutes != null ? Value(estimatedMinutes!) : const Value.absent(),
      isRecurring: recurring != null ? const Value(true) : const Value(false),
      recurringPattern: recurring != null ? Value(_getRecurringString()) : const Value.absent(),
    );
  }

  String _getRecurringString() {
    if (recurring == null) return '';
    switch (recurring!) {
      case RecurringPattern.daily:
        return 'daily';
      case RecurringPattern.weekly:
        return 'weekly';
      case RecurringPattern.monthly:
        return 'monthly';
      case RecurringPattern.weeklyOnMonday:
        return 'weekly;1';
      case RecurringPattern.weeklyOnTuesday:
        return 'weekly;2';
      case RecurringPattern.weeklyOnWednesday:
        return 'weekly;3';
      case RecurringPattern.weeklyOnThursday:
        return 'weekly;4';
      case RecurringPattern.weeklyOnFriday:
        return 'weekly;5';
      case RecurringPattern.weeklyOnSaturday:
        return 'weekly;6';
      case RecurringPattern.weeklyOnSunday:
        return 'weekly;7';
    }
  }
}

/// Recurring Pattern Enum
enum RecurringPattern {
  daily,
  weekly,
  monthly,
  weeklyOnMonday,
  weeklyOnTuesday,
  weeklyOnWednesday,
  weeklyOnThursday,
  weeklyOnFriday,
  weeklyOnSaturday,
  weeklyOnSunday,
}
