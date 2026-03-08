import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import 'bloc/voice_bloc.dart';
import '../tasks/bloc/task_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../../data/datasources/local/database.dart';

/// Voice Command Page
class VoiceCommandPage extends StatefulWidget {
  const VoiceCommandPage({super.key});

  @override
  State<VoiceCommandPage> createState() => _VoiceCommandPageState();
}

class _VoiceCommandPageState extends State<VoiceCommandPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<VoiceBloc>().add(VoiceInitialize());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Command'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showVoiceHelp(context),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<VoiceBloc, VoiceState>(
          listener: (context, state) {
            // Only show error if widget is still mounted and error is not null
            if (state.error != null && mounted) {
              Future.microtask(() {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              });
            }
            // Show recognized text when available
            if (state.recognizedText.isNotEmpty && !state.isListening && mounted) {
              Future.microtask(() {
                if (mounted) {
                  _processCommand(state.recognizedText);
                }
              });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Voice Input Section
                  _buildVoiceInputSection(context, state),

                  const SizedBox(height: 24),

                  // Text Input (for manual entry)
                  _buildTextInputSection(context),

                  const SizedBox(height: 24),

                  // Example Commands
                  _buildExampleCommands(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVoiceInputSection(BuildContext context, VoiceState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Listening Animation
          if (state.isListening) ...[
            _buildListeningAnimation(),
            const SizedBox(height: 24),
          ],

          // Voice Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (state.isListening) {
                context.read<VoiceBloc>().add(VoiceStopListening());
              } else {
                context.read<VoiceBloc>().add(VoiceStartListening());
              }
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                state.isListening ? Icons.mic : Icons.mic_none,
                size: 40,
                color: AppConstants.primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Status Text
          Text(
            state.isListening ? 'Mendengarkan...' : 'Ketuk untuk mulai bicara',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),

          // Recognized Text
          if (state.recognizedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.recognizedText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListeningAnimation() {
    return SizedBox(
      height: 60,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 40 + (index % 3) * 20.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTextInputSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atau ketik perintah:',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Contoh: Tambah task meeting besok jam 2 siang prioritas 1',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () {
                  _textController.clear();
                  context.read<VoiceBloc>().add(VoiceReset());
                },
                icon: const Icon(Icons.clear),
                label: const Text('Hapus'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _processCommand(_textController.text),
                icon: const Icon(Icons.add_task),
                label: const Text('Proses'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExampleCommands(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contoh Perintah Suara:',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildExampleCard(
          context,
          command: 'Tambah task meeting dengan tim',
          result: 'Task: "Meeting dengan tim"',
        ),
        _buildExampleCard(
          context,
          command: 'Buat task rapat besok jam 2 siang',
          result: 'Task: "Rapat"\nDue: Besok 14:00\nPriority: Normal',
        ),
        _buildExampleCard(
          context,
          command: 'Task pentang selasa depannya',
          result: 'Task: "Pentang"\nDue: Selasa depan\nPriority: P1 (Urgent)',
        ),
      ],
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String command,
    required String result,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mic, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    command,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.arrow_forward,
                    size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processCommand(String text) {
    if (text.trim().isEmpty) return;

    final task = VoiceCommandParser.parse(text);

    if (task.type == CommandType.addTask) {
      // Actually add the task to database
      final newTask = TasksCompanion.insert(
        title: task.title,
        description: const Value(null),
        priority: const Value(3),
        status: const Value(1),
        dueDate: Value(DateTime.now()),
        createdAt: Value(DateTime.now()),
      );

      context.read<TaskBloc>().add(AddTask(newTask));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" ditambahkan!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (task.type == CommandType.addProject) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${task.title}" dibuat!'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    // Clear input
    _textController.clear();
    context.read<VoiceBloc>().add(VoiceReset());
  }

  void _showVoiceHelp(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomContext) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomContext).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panduan Perintah Suara',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Kata Kunci:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildHelpItem('Tambah task / Buat task', 'Membuat tugas baru'),
                  _buildHelpItem('Tambah project / Buat project', 'Membuat proyek baru'),
                  _buildHelpItem('Besok / lusa', 'Mengatur due date'),
                  _buildHelpItem('Jam / Pagi / Siang / Sore / Malam', 'Mengatur waktu'),
                  _buildHelpItem('Prioritas 1 / P1 / Penting', 'Set prioritas tinggi'),
                  _buildHelpItem('Setiap hari / Mingguan', 'Membuat recurring task'),

                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.pop(bottomContext),
                    child: const Text('Mengerti'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem(String keyword, String description) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              keyword,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

/// Voice Command Data
class VoiceCommand {
  final CommandType type;
  final String title;
  final DateTime? dueDate;
  final int? priority;

  VoiceCommand({
    required this.type,
    required this.title,
    this.dueDate,
    this.priority,
  });
}

/// Command Type
enum CommandType {
  addTask,
  addProject,
}

/// Voice Command Parser
class VoiceCommandParser {
  static VoiceCommand parse(String text) {
    final lowerText = text.toLowerCase().trim();

    // Check for project creation
    if (lowerText.contains('project') ||
        lowerText.contains('proyek')) {
      final title = _extractProjectTitle(lowerText);
      return VoiceCommand(
        type: CommandType.addProject,
        title: title,
      );
    }

    // Default to task creation
    final title = _extractTaskTitle(lowerText);
    final dueDate = _extractDueDate(lowerText);
    final priority = _extractPriority(lowerText);

    return VoiceCommand(
      type: CommandType.addTask,
      title: title,
      dueDate: dueDate,
      priority: priority,
    );
  }

  static String _extractTaskTitle(String text) {
    // Remove keywords and get the title
    String cleaned = text
        .replaceAll(RegExp(r'(tambah|buat|task|tugas|project|proyek|untuk|dengan)'), '')
        .replaceAll(RegExp(r'(besok|lusa|hari ini|pagi|siang|sore|malam|jam|'
            r'prioritas|priority|penting|urgent)'), '')
        .trim();

    if (cleaned.isEmpty) {
      return 'Tugas Baru';
    }

    // Capitalize first letter
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  static String _extractProjectTitle(String text) {
    String cleaned = text
        .replaceAll(RegExp(r'(tambah|buat|project|proyek|untuk|dengan)'), '')
        .trim();

    if (cleaned.isEmpty) {
      return 'Proyek Baru';
    }

    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  static DateTime? _extractDueDate(String text) {
    final now = DateTime.now();

    if (text.contains('besok')) {
      return now.add(const Duration(days: 1));
    } else if (text.contains('lusa')) {
      return now.add(const Duration(days: 2));
    } else if (text.contains('hari ini')) {
      return now;
    }

    return null;
  }

  static int? _extractPriority(String text) {
    if (text.contains('p1') || text.contains('prioritas 1') ||
        text.contains('penting') || text.contains('urgent')) {
      return 1;
    } else if (text.contains('p2')) {
      return 2;
    } else if (text.contains('p3')) {
      return 3;
    } else if (text.contains('p4')) {
      return 4;
    }

    return null;
  }
}
