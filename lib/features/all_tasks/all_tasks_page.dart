import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/tasks/bloc/task_bloc.dart';
import '../../shared/widgets/task_card.dart';
import '../../core/constants/app_constants.dart';
import 'package:drift/drift.dart' hide Column;
import '../../data/datasources/local/database.dart';

/// All Tasks Page - Display all tasks with filtering and layout options
class AllTasksPage extends StatefulWidget {
  const AllTasksPage({super.key});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

enum TaskLayout { list, board }
enum TaskGroupBy { none, date, deadline, priority, category }
enum TaskSortBy { dateAsc, dateDesc, priorityAsc, priorityDesc }

class _AllTasksPageState extends State<AllTasksPage> {
  TaskLayout _selectedLayout = TaskLayout.list;
  TaskGroupBy _selectedGroupBy = TaskGroupBy.none;
  TaskSortBy _selectedSortBy = TaskSortBy.dateAsc;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadAllTasks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: theme.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Semua Tugas',
                              style: theme.textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<TaskBloc, TaskState>(
                              builder: (context, state) {
                                final allTasks = state.allTasks;
                                final completed = allTasks.where((t) => t.status == 2).length;
                                final pending = allTasks.where((t) => t.status != 2).length;
                                return Text(
                                  '$pending pending • $completed selesai',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        // Settings Popup Button
                        IconButton(
                          onPressed: () => _showSettingsPopup(context),
                          icon: const Icon(Icons.filter_list),
                          tooltip: 'Filter & Layout',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Filters
                    _buildQuickFilters(context),
                  ],
                ),
              ),
            ),

            // Tasks List
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  var tasks = List<TaskData>.from(state.allTasks);

                  // Filter completed
                  if (!_showCompleted) {
                    tasks = tasks.where((t) => t.status != 2).toList();
                  }

                  // Sort tasks
                  tasks = _sortTasks(tasks);

                  // Group and display
                  if (_selectedGroupBy == TaskGroupBy.none) {
                    return _buildTaskList(context, tasks);
                  } else {
                    return _buildGroupedTaskList(context, tasks);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskOptions(context),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return Row(
      children: [
        _buildQuickFilterChip(
          context,
          label: 'Semua',
          isSelected: _showCompleted == true && _selectedGroupBy == TaskGroupBy.none,
          onTap: () => setState(() {
            _showCompleted = true;
            _selectedGroupBy = TaskGroupBy.none;
          }),
        ),
        const SizedBox(width: 8),
        _buildQuickFilterChip(
          context,
          label: 'Pending',
          isSelected: _showCompleted == false && _selectedGroupBy == TaskGroupBy.none,
          onTap: () => setState(() {
            _showCompleted = false;
            _selectedGroupBy = TaskGroupBy.none;
          }),
        ),
        const SizedBox(width: 8),
        _buildQuickFilterChip(
          context,
          label: 'By Date',
          isSelected: _selectedGroupBy == TaskGroupBy.date,
          onTap: () => setState(() => _selectedGroupBy = TaskGroupBy.date),
        ),
        const SizedBox(width: 8),
        _buildQuickFilterChip(
          context,
          label: 'By Priority',
          isSelected: _selectedGroupBy == TaskGroupBy.priority,
          onTap: () => setState(() => _selectedGroupBy = TaskGroupBy.priority),
        ),
        const SizedBox(width: 8),
        _buildQuickFilterChip(
          context,
          label: 'By Category',
          isSelected: _selectedGroupBy == TaskGroupBy.category,
          onTap: () => setState(() => _selectedGroupBy = TaskGroupBy.category),
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: AppConstants.primaryColor,
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: isSelected ? AppConstants.primaryColor : null,
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskData> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    if (_selectedLayout == TaskLayout.board) {
      return _buildBoardLayout(context, tasks);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TaskCard(
            task: tasks[index],
            onTap: () => _showTaskDetail(context, tasks[index]),
            onComplete: () => _toggleTaskStatus(tasks[index]),
            onDelete: () => _deleteTask(context, tasks[index].id),
          ),
        );
      },
    );
  }

  Widget _buildBoardLayout(BuildContext context, List<TaskData> tasks) {
    // Group by status (Pending, Completed)
    final pendingTasks = tasks.where((t) => t.status != 2).toList();
    final completedTasks = tasks.where((t) => t.status == 2).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoardHeader('Pending', AppConstants.warningColor, pendingTasks.length),
                const SizedBox(height: 12),
                ...pendingTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCard(
                        task: task,
                        onTap: () => _showTaskDetail(context, task),
                        onComplete: () => _toggleTaskStatus(task),
                        onDelete: () => _deleteTask(context, task.id),
                      ),
                    )),
                if (pendingTasks.isEmpty)
                  _buildEmptyBoardCard('Tidak ada tugas pending'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Completed Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBoardHeader('Selesai', AppConstants.successColor, completedTasks.length),
                const SizedBox(height: 12),
                ...completedTasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCard(
                        task: task,
                        onTap: () => _showTaskDetail(context, task),
                        onComplete: () => _toggleTaskStatus(task),
                        onDelete: () => _deleteTask(context, task.id),
                      ),
                    )),
                if (completedTasks.isEmpty)
                  _buildEmptyBoardCard('Tidak ada tugas selesai'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardHeader(String title, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBoardCard(String text) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedTaskList(BuildContext context, List<TaskData> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    final groups = _groupTasks(tasks);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final groupName = groups.keys.elementAt(index);
        final groupTasks = groups[groupName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(context, groupName, groupTasks.length),
            const SizedBox(height: 8),
            ...groupTasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(
                    task: task,
                    onTap: () => _showTaskDetail(context, task),
                    onComplete: () => _toggleTaskStatus(task),
                    onDelete: () => _deleteTask(context, task.id),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildGroupHeader(BuildContext context, String groupName, int count) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          groupName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada tugas',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan + untuk membuat tugas baru',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsPopup(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 16),
              Text(
                'Tampilan Tugas',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Layout Options
              Text(
                'Layout',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<TaskLayout>(
                segments: const [
                  ButtonSegment(
                    value: TaskLayout.list,
                    label: Text('List'),
                    icon: Icon(Icons.list),
                  ),
                  ButtonSegment(
                    value: TaskLayout.board,
                    label: Text('Board'),
                    icon: Icon(Icons.view_column),
                  ),
                ],
                selected: {_selectedLayout},
                onSelectionChanged: (Set<TaskLayout> newSelection) {
                  setSheetState(() => _selectedLayout = newSelection.first);
                  setState(() => _selectedLayout = newSelection.first);
                },
              ),
              const SizedBox(height: 24),

              // Show Completed Toggle
              SwitchListTile(
                title: const Text('Tampilkan Selesai'),
                subtitle: const Text('Tampilkan tugas yang sudah selesai'),
                value: _showCompleted,
                onChanged: (value) {
                  setSheetState(() => _showCompleted = value);
                  setState(() => _showCompleted = value);
                },
              ),
              const SizedBox(height: 16),

              // Group By Options
              Text(
                'Group By',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: TaskGroupBy.values.map((groupBy) {
                  final label = _getGroupByLabel(groupBy);
                  return FilterChip(
                    label: Text(label),
                    selected: _selectedGroupBy == groupBy,
                    onSelected: (selected) {
                      setSheetState(() => _selectedGroupBy = selected ? groupBy : TaskGroupBy.none);
                      setState(() => _selectedGroupBy = selected ? groupBy : TaskGroupBy.none);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Sort By Options
              Text(
                'Sort By',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: TaskSortBy.values.map((sortBy) {
                  final label = _getSortByLabel(sortBy);
                  return FilterChip(
                    label: Text(label),
                    selected: _selectedSortBy == sortBy,
                    onSelected: (selected) {
                      setSheetState(() => _selectedSortBy = sortBy);
                      setState(() => _selectedSortBy = sortBy);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getGroupByLabel(TaskGroupBy groupBy) {
    switch (groupBy) {
      case TaskGroupBy.none:
        return 'None';
      case TaskGroupBy.date:
        return 'Tanggal';
      case TaskGroupBy.deadline:
        return 'Deadline';
      case TaskGroupBy.priority:
        return 'Prioritas';
      case TaskGroupBy.category:
        return 'Kategori';
    }
  }

  String _getSortByLabel(TaskSortBy sortBy) {
    switch (sortBy) {
      case TaskSortBy.dateAsc:
        return 'Tanggal ▲';
      case TaskSortBy.dateDesc:
        return 'Tanggal ▼';
      case TaskSortBy.priorityAsc:
        return 'Prioritas ▲';
      case TaskSortBy.priorityDesc:
        return 'Prioritas ▼';
    }
  }

  List<TaskData> _sortTasks(List<TaskData> tasks) {
    switch (_selectedSortBy) {
      case TaskSortBy.dateAsc:
        tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case TaskSortBy.dateDesc:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortBy.priorityAsc:
        tasks.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case TaskSortBy.priorityDesc:
        tasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
    }
    return tasks;
  }

  Map<String, List<TaskData>> _groupTasks(List<TaskData> tasks) {
    final Map<String, List<TaskData>> groups = {};

    for (final task in tasks) {
      String groupKey;

      switch (_selectedGroupBy) {
        case TaskGroupBy.date:
          final date = task.createdAt;
          groupKey = _formatDate(date);
          break;
        case TaskGroupBy.deadline:
          final deadline = task.dueDate;
          groupKey = deadline != null ? _formatDate(deadline) : 'No Deadline';
          break;
        case TaskGroupBy.priority:
          groupKey = 'P${task.priority}';
          break;
        case TaskGroupBy.category:
          final labels = task.labels ?? '';
          groupKey = labels.isNotEmpty ? labels : 'No Category';
          break;
        case TaskGroupBy.none:
          groupKey = 'All';
          break;
      }

      groups.putIfAbsent(groupKey, () => []).add(task);
    }

    return groups;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    final difference = taskDate.difference(today).inDays;

    if (difference == 0) return 'Hari Ini';
    if (difference == 1) return 'Besok';
    if (difference == -1) return 'Kemarin';
    if (difference > 1 && difference <= 7) return '${difference} Hari Lagi';
    if (difference < -1 && difference >= -7) return '${difference.abs()} Hari Lalu';

    return '${date.day}/${date.month}/${date.year}';
  }

  void _toggleTaskStatus(TaskData task) {
    final newStatus = task.status == 2 ? 1 : 2;
    context.read<TaskBloc>().add(UpdateTask(task.copyWith(status: newStatus)));
  }

  void _deleteTask(BuildContext context, int taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(taskId));
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetail(BuildContext context, TaskData task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskDetailSheet(task: task),
    );
  }

  void _showAddTaskOptions(BuildContext context) {
    context.push('/timer');
  }
}

/// Task Detail Sheet
class _TaskDetailSheet extends StatefulWidget {
  final TaskData task;

  const _TaskDetailSheet({required this.task});

  @override
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _selectedPriority;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _selectedPriority = widget.task.priority;
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
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
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Tugas',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTask(context),
                ),
              ],
            ),
          ),
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Prioritas',
                      border: OutlineInputBorder(),
                    ),
                    child: Wrap(
                      spacing: 8,
                      children: [1, 2, 3, 4].map((priority) {
                        final isSelected = _selectedPriority == priority;
                        final color = _getPriorityColor(priority);
                        return ChoiceChip(
                          label: Text('P$priority'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedPriority = priority);
                          },
                          selectedColor: color.withOpacity(0.2),
                          checkmarkColor: color,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _selectedDueDate != null
                          ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                          : 'Pilih Tanggal',
                    ),
                    onTap: () => _selectDueDate(context),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _saveTask(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      setState(() => _selectedDueDate = picked);
    }
  }

  void _saveTask(BuildContext context) {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: Value(_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim()),
      priority: _selectedPriority,
      dueDate: _selectedDueDate != null ? Value(_selectedDueDate) : const Value(null),
    );

    context.read<TaskBloc>().add(UpdateTask(updatedTask));
    Navigator.pop(context);
  }

  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(widget.task.id));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
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
