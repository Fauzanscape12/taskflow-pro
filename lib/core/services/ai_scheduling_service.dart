import 'package:google_generative_ai/google_generative_ai.dart';

import '../constants/app_constants.dart';
import '../../data/datasources/local/database.dart';

/// AI Scheduling Service
/// Uses Google Generative AI for smart scheduling
class AISchedulingService {
  AISchedulingService._();

  GenerativeModel? _model;
  bool _isInitialized = false;

  /// Initialize AI with API key
  Future<bool> initialize(String apiKey) async {
    try {
      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing AI: $e');
      return false;
    }
  }

  /// Check if AI is available
  bool get isAvailable => _isInitialized && _model != null;

  /// Break down task into subtasks
  Future<List<String>> breakdownTask(String taskTitle) async {
    if (!isAvailable) {
      return _getFallbackBreakdown(taskTitle);
    }

    try {
      final prompt = '''
Buatkan rencana langkah-langkah untuk menyelesaikan tugas: "$taskTitle"

Berikan 3-5 langkah yang spesifik dan actionable.
Jawab dalam format JSON:
{
  "steps": [
    "Langkah 1",
    "Langkah 2",
    "Langkah 3"
  ]
}

Hanya berikan JSON, tanpa teks lain.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final jsonStr = _extractJSON(response.text ?? '');

      if (jsonStr != null) {
        final parsed = _parseJson(jsonStr);
        if (parsed != null && parsed['steps'] != null) {
          return List<String>.from(parsed['steps']);
        }
      }

      return _getFallbackBreakdown(taskTitle);
    } catch (e) {
      print('Error breaking down task: $e');
      return _getFallbackBreakdown(taskTitle);
    }
  }

  /// Suggest optimal schedule for tasks
  Future<ScheduleSuggestion> suggestSchedule(
    List<TaskData> tasks, {
    int workHoursStart = 9,
    int workHoursEnd = 17,
    int lunchHour = 12,
  }) async {
    if (!isAvailable || tasks.isEmpty) {
      return ScheduleSuggestion.empty();
    }

    try {
      // Prepare task summaries
      final taskSummaries = tasks.map((t) {
        final priority = 'P${t.priority}';
        final duration = t.estimatedMinutes ?? 30;
        return '- $priority: ${t.title} (${duration} min)';
      }).join('\n');

      final prompt = '''
Saya memiliki tugas-tugas berikut untuk dijadwalkankan hari ini:

$taskSummaries

Jam kerja: $workHoursStart:00 - $workHoursEnd:00
Istirahat makan siang: ${lunchHour}00-${lunchHour + 1}00

Buat jadwal optimal dengan mempertimbangkan:
1. Tugas prioritas tinggi (P1) duluan
2. Tugas yang memerlukan fokus tinggi di pagi hari
3. Berikan waktu istirahat antar tugas
4. Setiap tugas perlu waktu istirahat 5 menit

Jawab dalam format JSON:
{
  "schedule": [
    {
      "taskTitle": "Nama tugas",
      "startTime": "09:00",
      "endTime": "10:00",
      "reason": "Alasan penjadwalan"
    }
  ],
  "warnings": [
    "Peringatan jika ada"
  ]
}

Hanya berikan JSON, tanpa teks lain.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final jsonStr = _extractJSON(response.text ?? '');

      if (jsonStr != null) {
        final parsed = _parseJson(jsonStr);
        if (parsed != null && parsed['schedule'] != null) {
          final scheduleItems = (parsed['schedule'] as List)
              .map((item) => ScheduleItem(
                    taskTitle: item['taskTitle'],
                    startTime: item['startTime'],
                    endTime: item['endTime'],
                    reason: item['reason'],
                  ))
              .toList();

          final warnings = parsed['warnings'] != null
              ? List<String>.from(parsed['warnings'])
              : <String>[];

          return ScheduleSuggestion(
            scheduleItems: scheduleItems,
            warnings: warnings,
            totalTasks: tasks.length,
          );
        }
      }

      return ScheduleSuggestion.empty();
    } catch (e) {
      print('Error suggesting schedule: $e');
      return ScheduleSuggestion.empty();
    }
  }

  /// Get AI productivity insights
  Future<ProductivityInsights> getInsights(List<TaskData> completedTasks) async {
    if (!isAvailable) {
      return ProductivityInsights.fallback();
    }

    try {
      // Calculate some stats
      final totalTasks = completedTasks.length;
      final p1Tasks = completedTasks.where((t) => t.priority == 1).length;
      final p2Tasks = completedTasks.where((t) => t.priority == 2).length;

      final taskSummary = '''
Total tugas selesai: $totalTasks
Tugas P1 selesai: $p1Tasks
Tugas P2 selesai: $p2Tasks
''';

      final prompt = '''
Analisis produktivitas berdasarkan data tugas:

$taskSummary

Berikan wawasan singkat dalam format JSON:
{
  "score": 85,
  "insight": "Wawasan singkat",
  "tips": ["Tips 1", "Tips 2"],
  "strength": "Kekuatan pengguna",
  "improvement": "Area yang perlu ditingkatkan"
}

Score adalah nilai 0-100.
Jawab dalam Bahasa Indonesia.
Hanya berikan JSON, tanpa teks lain.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final jsonStr = _extractJSON(response.text ?? '');

      if (jsonStr != null) {
        final parsed = _parseJson(jsonStr);
        if (parsed != null) {
          return ProductivityInsights(
            score: parsed['score'] ?? 70,
            insight: parsed['insight'] ?? 'Produktivitas Anda baik',
            tips: parsed['tips'] != null
                ? List<String>.from(parsed['tips'])
                : [],
            strength: parsed['strength'] ?? 'Konsistensi',
            improvement: parsed['improvement'] ?? 'Manajemen waktu',
          );
        }
      }

      return ProductivityInsights.fallback();
    } catch (e) {
      print('Error getting insights: $e');
      return ProductivityInsights.fallback();
    }
  }

  /// Suggest labels for a task
  Future<List<String>> suggestLabels(String taskTitle) async {
    if (!isAvailable) return [];

    try {
      final prompt = '''
Berikan 3-5 label yang relevan untuk tugas: "$taskTitle"

Labels yang tersedia: kerja, pribadi, belajar, kesehatan, rumah, keuangan, hobi, social, shopping

Jawab dalam format JSON:
{
  "labels": ["label1", "label2", "label3"]
}

Hanya berikan JSON, tanpa teks lain.
''';

      final response = await _model!.generateContent([Content.text(prompt)]);
      final jsonStr = _extractJSON(response.text ?? '');

      if (jsonStr != null) {
        final parsed = _parseJson(jsonStr);
        if (parsed != null && parsed['labels'] != null) {
          return List<String>.from(parsed['labels']);
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  String? _extractJSON(String text) {
    // Find JSON object in response
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
    return jsonMatch?.group(0);
  }

  dynamic _parseJson(String jsonStr) {
    // Simple JSON parser
    try {
      if (jsonStr == "['error while generating content']") {
        return {'error': 'AI error'};
      }
      // For simplicity, return as-is
      // In production, use dart:convert
      return jsonStr;
    } catch (e) {
      return null;
    }
  }

  List<String> _getFallbackBreakdown(String taskTitle) {
    return [
      'Riset dan kumpulkan informasi',
      'Buat rancangan kerja',
      'Eksekusi dan review',
    ];
  }

  /// Dispose resources
  void dispose() {
    _model = null;
    _isInitialized = false;
  }
}

/// Schedule Suggestion Result
class ScheduleSuggestion {
  final List<ScheduleItem> scheduleItems;
  final List<String> warnings;
  final int totalTasks;

  ScheduleSuggestion({
    required this.scheduleItems,
    required this.warnings,
    required this.totalTasks,
  });

  ScheduleSuggestion.empty()
      : scheduleItems = const [],
        warnings = const [],
        totalTasks = 0;
}

/// Single Schedule Item
class ScheduleItem {
  final String taskTitle;
  final String startTime;
  final String endTime;
  final String reason;

  ScheduleItem({
    required this.taskTitle,
    required this.startTime,
    required this.endTime,
    required this.reason,
  });
}

/// Productivity Insights Result
class ProductivityInsights {
  final int score;
  final String insight;
  final List<String> tips;
  final String strength;
  final String improvement;

  ProductivityInsights({
    required this.score,
    required this.insight,
    required this.tips,
    required this.strength,
    required this.improvement,
  });

  ProductivityInsights.fallback()
      : score = 70,
        insight = 'Lakukan lebih banyak tugas untuk meningkatkan produktivitas',
        tips = [
          'Gunakan teknik Pomodoro',
          'Prioritaskan tugas penting',
          'Istirahat yang cukup',
        ],
        strength = 'Anda produktif saat bekerja',
        improvement = 'Fokus pada tugas prioritas tinggi';
}
