import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/constants/app_constants.dart';
import '../tasks/bloc/task_bloc.dart';
import '../../data/datasources/local/database.dart';
import '../../models/task_category.dart';

/// Kanban Board Page
class KanbanBoardPage extends StatefulWidget {
  const KanbanBoardPage({super.key});

  @override
  State<KanbanBoardPage> createState() => _KanbanBoardPageState();
}

class _KanbanBoardPageState extends State<KanbanBoardPage> {
  // Filter: 0 = all, 1 = P1, 2 = P2, 3 = P3, 4 = P4
  int _priorityFilter = 0;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Filters
            _buildFilters(context),

            // Kanban Board
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  return _buildKanbanBoard(context, state.tasks);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.view_kanban,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kanban Board',
                    style: theme.textTheme.titleMedium,
                  ),
                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      final activeCount = state.tasks.where((t) => t.status != 2).length;
                      return Text(
                        '$activeCount tugas aktif',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(context, 'Semua', 0, _priorityFilter == 0),
            _buildFilterChip(context, 'P1', 1, _priorityFilter == 1),
            _buildFilterChip(context, 'P2', 2, _priorityFilter == 2),
            _buildFilterChip(context, 'P3', 3, _priorityFilter == 3),
            _buildFilterChip(context, 'P4', 4, _priorityFilter == 4),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, int value, bool isActive) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (selected) {
          setState(() {
            _priorityFilter = value;
          });
        },
        backgroundColor: isActive
            ? AppConstants.primaryColor.withOpacity(0.2)
            : null,
        selectedColor: AppConstants.primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: isActive ? Colors.white : null,
        ),
      ),
    );
  }

  Widget _buildKanbanBoard(BuildContext context, List<TaskData> allTasks) {
    // Filter tasks by priority
    var filteredTasks = allTasks;
    if (_priorityFilter > 0) {
      filteredTasks = allTasks.where((t) => t.priority == _priorityFilter).toList();
    }

    // Group tasks by status
    final todoTasks = filteredTasks.where((t) => t.status != 2).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    final doneTasks = filteredTasks.where((t) => t.status == 2).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    final columns = [
      _KanbanColumnData(
        id: 'todo',
        title: 'Akan Dikerjakan',
        color: AppConstants.warningColor,
        tasks: todoTasks,
        status: 1, // pending status
      ),
      _KanbanColumnData(
        id: 'done',
        title: 'Selesai',
        color: AppConstants.successColor,
        tasks: doneTasks,
        status: 2, // done status
      ),
    ];

    if (filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada tugas',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: columns.map((column) {
        return Expanded(
          child: _buildKanbanColumn(context, column),
        );
      }).toList(),
    );
  }

  Widget _buildKanbanColumn(BuildContext context, _KanbanColumnData column) {
    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        // Task dropped - update status
        final taskId = details.data;
        context.read<TaskBloc>().add(ToggleTaskStatus(taskId, column.status));
        HapticFeedback.lightImpact();
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: column.color.withOpacity(isDraggingOver ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: column.color.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              // Column Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        column.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: column.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${column.tasks.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tasks List
              Expanded(
                child: column.tasks.isEmpty
                    ? _buildEmptyColumn(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        itemCount: column.tasks.length,
                        itemBuilder: (context, index) {
                          return _buildKanbanCard(
                            context,
                            task: column.tasks[index],
                            columnColor: column.color,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyColumn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 32,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada tugas',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(
    BuildContext context, {
    required TaskData task,
    required Color columnColor,
  }) {
    final theme = Theme.of(context);

    return LongPressDraggable<int>(
      data: task.id,
      onDragStarted: () {
        HapticFeedback.lightImpact();
      },
      feedback: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: columnColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          task.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      child: GestureDetector(
        onTap: () => _showTaskDetail(context, task),
        onLongPress: () {
          HapticFeedback.mediumImpact();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: columnColor.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                task.title,
                style: theme.textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Description preview
              if (task.description != null && task.description!.isNotEmpty)
                Text(
                  task.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),

              // Tags/Category
              if (task.labels != null && task.labels!.isNotEmpty && !task.labels!.startsWith('dep:') && !task.labels!.startsWith('template:'))
                Wrap(
                  spacing: 4,
                  children: task.labels!.split(',').take(2).map((tag) {
                    final trimmed = tag.trim();
                    if (trimmed.startsWith('dep:') || trimmed.startsWith('template:')) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        trimmed,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 8),

              // Footer row
              Row(
                children: [
                  // Priority indicator
                  Icon(
                    Icons.flag,
                    size: 14,
                    color: _getPriorityColor(task.priority),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'P${task.priority}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getPriorityColor(task.priority),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  // Due date
                  if (task.dueDate != null)
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY();
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
        return AppConstants.priority3Color;
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Tugas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _filterOption(context, 'Semua Prioritas', 0),
              _filterOption(context, 'Hanya P1 - Urgent', 1),
              _filterOption(context, 'Hanya P2 - Tinggi', 2),
              _filterOption(context, 'Hanya P3 - Normal', 3),
              _filterOption(context, 'Hanya P4 - Rendah', 4),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(BuildContext context, String label, int value) {
    return ListTile(
      title: Text(label),
      trailing: Radio<int>(
        value: value,
        groupValue: _priorityFilter,
        onChanged: (value) {
          setState(() {
            _priorityFilter = value!;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDueDate;
    int selectedPriority = 3;
    String? selectedCategoryId;

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
                        'Tambah Tugas',
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

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
                                : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),

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
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),
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

                      String? labels;
                      if (selectedCategoryId != null) {
                        final category = PredefinedCategories.getById(selectedCategoryId!);
                        if (category != null) {
                          labels = category.name.toLowerCase();
                        }
                      }

                      final task = TasksCompanion.insert(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim().isEmpty
                            ? const drift.Value(null)
                            : drift.Value(descriptionController.text.trim()),
                        labels: drift.Value(labels),
                        priority: drift.Value(selectedPriority),
                        status: const drift.Value(1), // pending
                        dueDate: drift.Value(selectedDueDate ?? DateTime.now()),
                        createdAt: drift.Value(DateTime.now()),
                      );

                      context.read<TaskBloc>().add(AddTask(task));
                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tugas berhasil dibuat'),
                          backgroundColor: Colors.green,
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
                    child: const Text('Buat Tugas'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTaskDetail(BuildContext context, TaskData task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Tugas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task.description!),
            ],
            const SizedBox(height: 16),
            _detailRow('Prioritas', 'P${task.priority}'),
            _detailRow('Status', task.status == 2 ? 'Selesai' : 'Pending'),
            if (task.labels != null && !task.labels!.startsWith('dep:') && !task.labels!.startsWith('template:'))
              _detailRow('Kategori', task.labels!),
            if (task.dueDate != null)
              _detailRow('Deadline', '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Delete task
                      context.read<TaskBloc>().add(DeleteTask(task.id));
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Toggle status
                    final newStatus = task.status == 2 ? 1 : 2;
                    context.read<TaskBloc>().add(ToggleTaskStatus(task.id, newStatus));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                  ),
                  child: Text(task.status == 2 ? 'Tandai Pending' : 'Tandai Selesai'),
                ),
              ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kanban Column Data
class _KanbanColumnData {
  final String id;
  final String title;
  final Color color;
  final List<TaskData> tasks;
  final int status;

  _KanbanColumnData({
    required this.id,
    required this.title,
    required this.color,
    required this.tasks,
    required this.status,
  });
}
