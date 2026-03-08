import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/tasks/bloc/task_bloc.dart';
import '../../shared/widgets/task_card.dart';
import '../../core/constants/app_constants.dart';
import '../../models/task_category.dart';
import 'package:drift/drift.dart' hide Column;
import '../../data/datasources/local/database.dart';
import '../../features/voice/bloc/voice_bloc.dart';

/// Home Page - Today's Tasks with Category Filter
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedCategoryId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDueDate;
  int _selectedPriority = 3; // Default: P3 (Normal)

  // Task filter: 0 = pending, 1 = completed, 2 = all
  int _taskFilter = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTodayTasks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            Container(
              color: theme.scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Display
                        Text(
                          _getTodayDate(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Greeting
                        Text(
                          _getGreeting(),
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 24),

                        // Stats Row - Clickable Filter Tabs
                        BlocBuilder<TaskBloc, TaskState>(
                          buildWhen: (previous, current) =>
                              previous.todayTasks.length != current.todayTasks.length,
                          builder: (context, state) {
                            final completed = state.todayTasks.where((t) => t.status == 2).length;
                            final pending = state.todayTasks.where((t) => t.status != 2).length;
                            final total = state.todayTasks.length;

                            return Row(
                              children: [
                                _buildFilterTab(
                                  context,
                                  icon: Icons.check_circle_outline,
                                  label: 'Selesai',
                                  value: '$completed',
                                  color: AppConstants.successColor,
                                  isSelected: _taskFilter == 1,
                                  onTap: () => setState(() => _taskFilter = 1),
                                ),
                                const SizedBox(width: 12),
                                _buildFilterTab(
                                  context,
                                  icon: Icons.pending_outlined,
                                  label: 'Pending',
                                  value: '$pending',
                                  color: AppConstants.warningColor,
                                  isSelected: _taskFilter == 0,
                                  onTap: () => setState(() => _taskFilter = 0),
                                ),
                                const SizedBox(width: 12),
                                _buildFilterTab(
                                  context,
                                  icon: Icons.timer_outlined,
                                  label: 'Total',
                                  value: '$total',
                                  color: AppConstants.primaryColor,
                                  isSelected: _taskFilter == 2,
                                  onTap: () => setState(() => _taskFilter = 2),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Category Filter Chips
                        _buildCategoryFilters(theme),
                        const SizedBox(height: 16),

                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategoryId != null
                                  ? '${PredefinedCategories.getById(_selectedCategoryId!)?.name ?? 'Tugas'}'
                                  : 'Semua Tugas',
                              style: theme.textTheme.titleLarge,
                            ),
                            TextButton.icon(
                              onPressed: _selectedCategoryId != null
                                  ? () => setState(() => _selectedCategoryId = null)
                                  : () => _showCategoriesManagement(context),
                              icon: Icon(_selectedCategoryId != null
                                  ? Icons.clear
                                  : Icons.manage_accounts, size: 20),
                              label: Text(_selectedCategoryId != null ? 'Reset' : 'Kelola'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tasks List - Expanded to fill remaining space
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter tasks by selected category (using labels field)
                  var allTasks = state.todayTasks.toList(); // Create mutable copy
                  if (_selectedCategoryId != null) {
                    final category = PredefinedCategories.getById(_selectedCategoryId!);
                    if (category != null) {
                      allTasks = allTasks.where((t) {
                        final labels = t.labels ?? '';
                        return labels.split(',').contains(category.name.toLowerCase());
                      }).toList();
                    }
                  }

                  // Apply filter: pending, completed, or all
                  List<TaskData> pendingTasks = [];
                  List<TaskData> completedTasks = [];

                  if (_taskFilter == 0) {
                    // Show only pending
                    pendingTasks = allTasks.where((t) => t.status != 2).toList();
                    completedTasks = [];
                  } else if (_taskFilter == 1) {
                    // Show only completed
                    pendingTasks = [];
                    completedTasks = allTasks.where((t) => t.status == 2).toList();
                  } else {
                    // Show all: separate pending and completed
                    pendingTasks = allTasks.where((t) => t.status != 2).toList();
                    completedTasks = allTasks.where((t) => t.status == 2).toList();
                  }

                  // Sort by priority
                  pendingTasks.sort((a, b) => a.priority.compareTo(b.priority));
                  completedTasks.sort((a, b) => a.priority.compareTo(b.priority));

                  // Combine: pending first, then completed
                  final tasks = [...pendingTasks, ...completedTasks];

                  if (tasks.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final isCompletedSection = index >= pendingTasks.length;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: TaskCard(
                          task: task,
                          onTap: () => _showTaskDetail(context, task),
                          onComplete: () => _toggleTaskStatus(context, task),
                          onDelete: () => _deleteTask(context, task.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    const weekdays = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi! 👋';
    if (hour < 15) return 'Selamat Siang! ☀️';
    if (hour < 18) return 'Selamat Sore! 🌤️';
    return 'Selamat Malam! 🌙';
  }

  Widget _buildFilterTab(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.white.withOpacity(0.9) : color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(ThemeData theme) {
    final categories = PredefinedCategories.all.take(8).toList();

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          // "All" option
          if (index == 0) {
            final isSelected = _selectedCategoryId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Semua'),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedCategoryId = null),
                backgroundColor: Colors.grey.shade200,
                selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                checkmarkColor: AppConstants.primaryColor,
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = _selectedCategoryId == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Text(category.icon),
              label: Text(category.name),
              selected: isSelected,
              onSelected: (_) => setState(() {
                _selectedCategoryId = isSelected ? null : category.id;
              }),
              backgroundColor: category.colorValue.withOpacity(0.15),
              selectedColor: category.colorValue.withOpacity(0.3),
              checkmarkColor: category.colorValue,
              labelStyle: TextStyle(
                color: isSelected ? category.colorValue : theme.colorScheme.onSurface,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tugas hari ini',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan + untuk menambah tugas baru',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddMethodSelector(context),
      backgroundColor: AppConstants.primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showAddMethodSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Tambah Tugas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            // Opsi 1: Tambah Manual
            _buildMethodOption(
              context,
              icon: Icons.edit,
              title: 'Input Manual',
              description: 'Isi judul, deskripsi, dan detail tugas',
              color: AppConstants.primaryColor,
              onTap: () {
                Navigator.pop(bottomContext);
                _showAddTaskBottomSheet(context);
              },
            ),

            const SizedBox(height: 12),

            // Opsi 2: Voice Command
            _buildMethodOption(
              context,
              icon: Icons.mic,
              title: 'Voice Command',
              description: 'Bicara untuk membuat tugas dengan cepat',
              color: AppConstants.warningColor,
              onTap: () {
                Navigator.pop(bottomContext);
                _showVoiceCommandTaskSheet(context);
              },
            ),

            const SizedBox(height: 12),

            // Opsi 3: Pilih Template
            _buildMethodOption(
              context,
              icon: Icons.dashboard_customize,
              title: 'Gunakan Template',
              description: 'Pilih template untuk membuat banyak tugas',
              color: AppConstants.infoColor,
              onTap: () {
                Navigator.pop(bottomContext);
                _showTemplateSelector(context);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildMethodOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceCommandTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (voiceContext) => BlocProvider(
        create: (_) => VoiceBloc()..add(VoiceInitialize()),
        child: _VoiceTaskSheet(onTaskCreated: (task) {
          context.read<TaskBloc>().add(AddTask(task));
          Navigator.pop(voiceContext);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tugas berhasil dibuat via voice!'),
              backgroundColor: Colors.green,
            ),
          );
        }),
      ),
    );
  }

  void _showTemplateSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (templateContext) => _TemplateSelectorSheet(
        onTemplateSelected: (template) {
          _useTemplate(context, template);
        },
      ),
    );
  }

  void _useTemplate(BuildContext context, ProjectTemplate template) {
    final now = DateTime.now();
    final taskBloc = context.read<TaskBloc>();

    for (final taskData in template.tasks) {
      final task = TasksCompanion.insert(
        title: taskData['title'],
        description: taskData['description'] != null && taskData['description'].toString().isNotEmpty
            ? const Value(null)
            : Value(taskData['description']),
        priority: const Value(3),
        status: taskData['default'] == true ? const Value(2) : const Value(1),
        dueDate: Value(now),
        createdAt: Value(now),
        labels: Value('template:${template.id}'),
      );

      taskBloc.add(AddTask(task));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${template.tasks.length} tugas dari template "${template.name}" berhasil dibuat!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    // Local state for bottom sheet
    String? localCategoryId;
    DateTime? localDueDate;
    int localPriority = 3;

    // Clear previous inputs
    _titleController.clear();
    _descriptionController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final theme = Theme.of(context);

          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tambah Tugas Baru',
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title input with voice
                  BlocProvider(
                    create: (_) => VoiceBloc()..add(VoiceInitialize()),
                    child: BlocBuilder<VoiceBloc, VoiceState>(
                      builder: (voiceContext, voiceState) {
                        return TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Judul tugas...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                voiceState.isListening
                                    ? Icons.mic
                                    : Icons.mic_none,
                                color: voiceState.isListening
                                    ? Colors.red
                                    : AppConstants.primaryColor,
                              ),
                              onPressed: () {
                                if (voiceState.isListening) {
                                  voiceContext.read<VoiceBloc>().add(VoiceStopListening());
                                } else {
                                  voiceContext.read<VoiceBloc>().add(VoiceStartListening());
                                }
                              },
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            voiceContext.read<VoiceBloc>().add(VoiceTextChanged(value));
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Voice status indicator
                  BlocProvider(
                    create: (_) => VoiceBloc()..add(VoiceInitialize()),
                    child: BlocListener<VoiceBloc, VoiceState>(
                      listener: (voiceContext, voiceState) {
                        if (voiceState.recognizedText.isNotEmpty &&
                            !voiceState.isListening &&
                            _titleController.text.isEmpty) {
                          _titleController.text = voiceState.recognizedText;
                        }
                      },
                      child: BlocBuilder<VoiceBloc, VoiceState>(
                        builder: (voiceContext, voiceState) {
                          if (voiceState.isListening) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Mendengarkan...',
                                    style: TextStyle(
                                      color: AppConstants.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description input

                  // Description input
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Deskripsi (opsional)...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  // Category selector
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: localCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tanpa Kategori'),
                      ),
                      ...PredefinedCategories.all.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Row(
                            children: [
                              Text(cat.icon, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setSheetState(() {
                        localCategoryId = value;
                      });
                    },
                  ),

                  // Due date picker
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: localDueDate ?? now,
                        firstDate: now.subtract(const Duration(days: 365)),
                        lastDate: now.add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setSheetState(() {
                          localDueDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Deadline',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            localDueDate == null
                                ? 'Pilih tanggal'
                                : _formatDate(localDueDate!),
                            style: TextStyle(
                              color: localDueDate == null
                                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: AppConstants.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Priority selector
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Prioritas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    child: Wrap(
                      spacing: 8,
                      children: [1, 2, 3, 4].map((priority) {
                        final isSelected = localPriority == priority;
                        final color = _getPriorityColor(priority);
                        return ChoiceChip(
                          label: Text('P$priority'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setSheetState(() {
                              localPriority = priority;
                            });
                          },
                          selectedColor: color.withOpacity(0.2),
                          checkmarkColor: color,
                          labelStyle: TextStyle(
                            color: isSelected ? color : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save button
                  ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Judul tugas tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Create labels from category
                      String? labels;
                      if (localCategoryId != null) {
                        final category = PredefinedCategories.getById(localCategoryId!);
                        if (category != null) {
                          labels = category.name.toLowerCase();
                        }
                      }

                      // Create the task - default to today if no date selected
                      final task = TasksCompanion.insert(
                        title: _titleController.text.trim(),
                        description: _descriptionController.text.trim().isEmpty
                            ? const Value(null)
                            : Value(_descriptionController.text.trim()),
                        labels: Value(labels),
                        priority: Value(localPriority),
                        status: const Value(1), // 1 = pending
                        dueDate: Value(localDueDate ?? DateTime.now()),
                        createdAt: Value(DateTime.now()),
                      );

                      context.read<TaskBloc>().add(AddTask(task));

                      // Update parent state to refresh
                      setState(() {
                        _selectedCategoryId = localCategoryId;
                        _selectedDueDate = localDueDate;
                        _selectedPriority = localPriority;
                      });

                      Navigator.pop(sheetContext);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tugas berhasil dibuat'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Clear controllers
                      _titleController.clear();
                      _descriptionController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan Tugas'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleTaskStatus(BuildContext context, TaskData task) {
    final newStatus = task.status == 2 ? 1 : 2; // Toggle between pending (1) and completed (2)
    context.read<TaskBloc>().add(ToggleTaskStatus(task.id, newStatus));

    final message = newStatus == 2 ? 'Tugas selesai!' : 'Tugas dipending';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: newStatus == 2 ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _deleteTask(BuildContext context, int taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TaskBloc>().add(DeleteTask(taskId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tugas dihapus'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTaskDetail(BuildContext context, TaskData task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(task.description!),
                ),
              Text('Status: ${_getStatusText(task.status)}'),
              Text('Prioritas: P${task.priority}'),
              if (task.labels != null && task.labels!.isNotEmpty)
                Text('Label: ${task.labels}'),
              if (task.dueDate != null)
                Text('Deadline: ${_formatDate(task.dueDate!)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showEditTaskDialog(context, task);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, TaskData task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description ?? '');
    DateTime? selectedDueDate = task.dueDate;
    int selectedPriority = task.priority;
    String? selectedCategoryId;

    // Find category from labels
    if (task.labels != null && task.labels!.isNotEmpty) {
      final labelParts = task.labels!.split(',');
      for (final label in labelParts) {
        final category = PredefinedCategories.all.where((c) => c.name.toLowerCase() == label.trim().toLowerCase()).firstOrNull;
        if (category != null) {
          selectedCategoryId = category.id;
          break;
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final theme = Theme.of(context);

          return Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Tugas',
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title input
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Description input
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  // Category selector
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tanpa Kategori'),
                      ),
                      ...PredefinedCategories.all.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Row(
                            children: [
                              Text(cat.icon, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setSheetState(() {
                        selectedCategoryId = value;
                      });
                    },
                  ),

                  // Due date picker
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: selectedDueDate ?? now,
                        firstDate: now.subtract(const Duration(days: 365)),
                        lastDate: now.add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setSheetState(() {
                          selectedDueDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Deadline',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDueDate == null
                                ? 'Pilih tanggal'
                                : _formatDate(selectedDueDate!),
                            style: TextStyle(
                              color: selectedDueDate == null
                                  ? theme.colorScheme.onSurface.withOpacity(0.6)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: AppConstants.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Priority selector
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Prioritas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                    child: Wrap(
                      spacing: 8,
                      children: [1, 2, 3, 4].map((priority) {
                        final isSelected = selectedPriority == priority;
                        final color = _getPriorityColor(priority);
                        return ChoiceChip(
                          label: Text('P$priority'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setSheetState(() {
                              selectedPriority = priority;
                            });
                          },
                          selectedColor: color.withOpacity(0.2),
                          checkmarkColor: color,
                          labelStyle: TextStyle(
                            color: isSelected ? color : null,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save button
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Judul tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Create labels from category
                      String? labels;
                      if (selectedCategoryId != null) {
                        final category = PredefinedCategories.getById(selectedCategoryId!);
                        if (category != null) {
                          labels = category.name.toLowerCase();
                        }
                      }

                      // Create updated task
                      final updatedTask = task.copyWith(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? const Value(null)
                            : Value(descriptionController.text.trim()),
                        labels: Value(labels),
                        priority: selectedPriority,
                        dueDate: Value(selectedDueDate ?? DateTime.now()),
                      );

                      context.read<TaskBloc>().add(UpdateTask(updatedTask));
                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tugas berhasil diperbarui'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Selesai';
      default:
        return 'Todo';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppConstants.priority1Color; // Red - Urgent
      case 2:
        return AppConstants.priority2Color; // Orange - High
      case 3:
        return AppConstants.priority3Color; // Blue - Normal
      case 4:
        return AppConstants.priority4Color; // Gray - Low
      default:
        return Colors.grey;
    }
  }

  void _showCategoriesManagement(BuildContext context) {
    context.push('/categories');
  }
}

/// Voice Task Sheet - Create task via voice command
class _VoiceTaskSheet extends StatefulWidget {
  final Function(TasksCompanion) onTaskCreated;

  const _VoiceTaskSheet({
    required this.onTaskCreated,
  });

  @override
  State<_VoiceTaskSheet> createState() => _VoiceTaskSheetState();
}

class _VoiceTaskSheetState extends State<_VoiceTaskSheet> {
  String _recognizedText = '';
  int _selectedPriority = 3;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Voice Command',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<VoiceBloc, VoiceState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state.recognizedText.isNotEmpty && !state.isListening) {
                  setState(() {
                    _recognizedText = state.recognizedText;
                  });
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (state.isListening) {
                            context.read<VoiceBloc>().add(VoiceStopListening());
                          } else {
                            context.read<VoiceBloc>().add(VoiceStartListening());
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: state.isListening
                                  ? [
                                      AppConstants.warningColor.withOpacity(0.8),
                                      AppConstants.warningColor,
                                    ]
                                  : [
                                      AppConstants.primaryColor.withOpacity(0.8),
                                      AppConstants.primaryColor,
                                    ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (state.isListening
                                        ? AppConstants.warningColor
                                        : AppConstants.primaryColor)
                                    .withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: state.isListening
                              ? const Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                  size: 48,
                                )
                              : const Icon(
                                  Icons.mic_none,
                                  color: Colors.white70,
                                  size: 48,
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.isListening ? 'Mendengarkan...' : 'Ketuk mic untuk mulai',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: state.isListening
                              ? AppConstants.warningColor
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!state.isListening && _recognizedText.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppConstants.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contoh perintah:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppConstants.infoColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('• "Buat tugas belajar Flutter"',
                                  style: theme.textTheme.bodySmall),
                              Text('• "Tambah tugas meeting besok pagi"',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      if (_recognizedText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppConstants.primaryColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Teks yang dikenali:',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(_recognizedText),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Prioritas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        child: Wrap(
                          spacing: 8,
                          children: [1, 2, 3, ].map((priority) {
                            final isSelected = _selectedPriority == priority;
                            final color = _getPriorityColor(priority);
                            return ChoiceChip(
                              label: Text('P$priority'),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedPriority = priority;
                                });
                              },
                              selectedColor: color.withOpacity(0.2),
                              checkmarkColor: color,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton(
              onPressed: _recognizedText.isNotEmpty && !_isProcessing
                  ? () {
                      setState(() {
                        _isProcessing = true;
                      });

                      final task = TasksCompanion.insert(
                        title: _recognizedText,
                        priority: Value(_selectedPriority),
                        status: const Value(1),
                        dueDate: Value(DateTime.now()),
                        createdAt: Value(DateTime.now()),
                      );

                      widget.onTaskCreated(task);

                      setState(() {
                        _isProcessing = false;
                        _recognizedText = '';
                      });
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Buat Tugas'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppConstants.priority1Color;
      case 2:
        return AppConstants.priority2Color;
      case 3:
        return AppConstants.priority3Color;
      case 4:
        return AppConstants.priority4Color;
      default:
        return Colors.grey;
    }
  }
}

/// Template Selector Sheet
class _TemplateSelectorSheet extends StatelessWidget {
  final Function(ProjectTemplate) onTemplateSelected;

  const _TemplateSelectorSheet({
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Template',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: PredefinedTemplates.featured.length,
              itemBuilder: (context, index) {
                final template = PredefinedTemplates.featured[index];
                final templateColor = _colorFromHex(template.color);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Text(
                      template.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(
                      template.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: templateColor,
                      ),
                    ),
                    subtitle: Text(template.description),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: templateColor.withOpacity(0.7),
                    ),
                    onTap: () {
                      onTemplateSelected(template);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 7 && hexColor[0] == '#') {
      buffer.write('0xFF');
      buffer.write(hexColor.substring(1));
    } else if (hexColor.length == 6) {
      buffer.write('0xFF');
      buffer.write(hexColor);
    }
    return Color(int.parse(buffer.toString()));
  }
}

/// Predefined Templates (simplified for quick access)
class PredefinedTemplates {
  static List<ProjectTemplate> get featured => [
        ProjectTemplate(
          id: 'work',
          name: 'Pekerjaan',
          icon: '💼',
          description: 'Email, deep work, meeting, review',
          category: 'Work',
          color: '#3B82F6',
          tasks: [
            {'title': 'Email & komunikasi', 'default': true},
            {'title': 'Deep work', 'default': true},
            {'title': 'Meeting harian'},
            {'title': 'Review harian'},
            {'title': 'Planning besok'},
          ],
        ),
        ProjectTemplate(
          id: 'learning',
          name: 'Belajar',
          icon: '📚',
          description: 'Baca buku, praktik, review',
          category: 'Personal',
          color: '#10B981',
          tasks: [
            {'title': 'Baca buku', 'default': true},
            {'title': 'Praktik'},
            {'title': 'Note taking'},
            {'title': 'Review'},
          ],
        ),
        ProjectTemplate(
          id: 'health',
          name: 'Kesehatan',
          icon: '🏃',
          description: 'Olahraga, makan sehat, tidur cukup',
          category: 'Health',
          color: '#EF4444',
          tasks: [
            {'title': 'Olahraga pagi', 'default': true},
            {'title': 'Minum air'},
            {'title': 'Makan sehat'},
            {'title': 'Tidur cukup'},
          ],
        ),
      ];
}

/// Project Template Data Model (simplified)
class ProjectTemplate {
  final String id;
  final String name;
  final String icon;
  final String description;
  final String category;
  final String color;
  final List<Map<String, dynamic>> tasks;

  ProjectTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.category,
    required this.color,
    required this.tasks,
  });
}
