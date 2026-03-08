import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drift/drift.dart' as drift;

import '../../data/datasources/local/database.dart';
import '../../core/constants/app_constants.dart';
import '../tasks/bloc/task_bloc.dart';

/// Task Dependencies Page
class TaskDependenciesPage extends StatefulWidget {
  const TaskDependenciesPage({super.key});

  @override
  State<TaskDependenciesPage> createState() => _TaskDependenciesPageState();
}

class _TaskDependenciesPageState extends State<TaskDependenciesPage> {
  Set<String> _expandedTasks = {};

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ketergantungan Tugas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDependencyDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppConstants.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap tugas untuk melihat dependensi. Gunakan + untuk menambahkan ketergantungan antar tugas.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                return _buildTasksList(context, state.tasks);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, List<TaskData> allTasks) {
    final theme = Theme.of(context);

    if (allTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.link_off,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada tugas',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showAddDependencyDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Tugas'),
            ),
          ],
        ),
      );
    }

    // Filter tasks that have dependencies or are depended upon
    final tasksWithDependencies = allTasks.map((task) {
      final dependencies = _getDependencies(task, allTasks);
      final dependents = _getDependents(task, allTasks);
      return _TaskWithDependency(
        id: task.id.toString(),
        task: task,
        priority: task.priority,
        dependencies: dependencies,
        dependents: dependents,
      );
    }).where((t) => t.dependencies.isNotEmpty || t.dependents.isNotEmpty)
     .toList()
       ..sort((a, b) => a.priority.compareTo(b.priority));

    if (tasksWithDependencies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada ketergantungan tugas',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showAddDependencyDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Ketergantungan'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasksWithDependencies.length,
      itemBuilder: (context, index) {
        final task = tasksWithDependencies[index];
        final isExpanded = _expandedTasks.contains(task.id);

        return Column(
          children: [
            // Task Card
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_expandedTasks.contains(task.id)) {
                    _expandedTasks.remove(task.id);
                  } else {
                    _expandedTasks.add(task.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPriorityColor(task.priority).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Priority Indicator
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.task.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          if (task.dependencies.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.block,
                                    size: 14,
                                    color: AppConstants.warningColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Tergantung pada ${task.dependencies.length} tugas',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppConstants.warningColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (task.dependents.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.call_made,
                                    size: 14,
                                    color: AppConstants.infoColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Dibutuhkan oleh ${task.dependents.length} tugas',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppConstants.infoColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Expand Icon
                    Icon(
                      isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),

            // Dependencies (when expanded)
            if (isExpanded && task.dependencies.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...task.dependencies.map((depTask) {
                return _buildDependencyItem(context, depTask: depTask, isDependency: true);
              }),
            ],

            // Dependents (when expanded)
            if (isExpanded && task.dependents.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...task.dependents.map((depTask) {
                return _buildDependencyItem(context, depTask: depTask, isDependency: false);
              }),
            ],

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildDependencyItem(
    BuildContext context, {
    required TaskData depTask,
    required bool isDependency,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 32, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDependency
            ? AppConstants.warningColor.withOpacity(0.1)
            : AppConstants.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDependency
                  ? AppConstants.warningColor
                  : AppConstants.infoColor)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDependency ? Icons.block : Icons.call_made,
            size: 16,
            color: isDependency
                ? AppConstants.warningColor
                : AppConstants.infoColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  depTask.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (depTask.status == 2)
                  Text(
                    'Sudah selesai',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppConstants.successColor,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            isDependency ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: isDependency ? -0.3 : 0.3);
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

  // Get tasks that this task depends on
  List<TaskData> _getDependencies(TaskData task, List<TaskData> allTasks) {
    final dependencies = <TaskData>[];

    // Parse dependencies from labels
    final labels = task.labels ?? '';
    if (labels.contains('dep:')) {
      final parts = labels.split(',');
      for (final part in parts) {
        if (part.trim().startsWith('dep:')) {
          final depIdStr = part.trim().substring(4); // Remove 'dep:'
          final depId = int.tryParse(depIdStr);
          if (depId != null) {
            final depTask = allTasks.where((t) => t.id == depId).firstOrNull;
            if (depTask != null) {
              dependencies.add(depTask);
            }
          }
        }
      }
    }

    return dependencies;
  }

  // Get tasks that depend on this task
  List<TaskData> _getDependents(TaskData task, List<TaskData> allTasks) {
    final dependents = <TaskData>[];
    final taskId = task.id.toString();

    for (final otherTask in allTasks) {
      if (otherTask.id == task.id) continue;

      final labels = otherTask.labels ?? '';
      if (labels.contains('dep:$taskId')) {
        dependents.add(otherTask);
      }
    }

    return dependents;
  }

  void _showAddDependencyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddDependencySheet(),
    );
  }
}

class _AddDependencySheet extends StatefulWidget {
  @override
  State<_AddDependencySheet> createState() => _AddDependencySheetState();
}

class _AddDependencySheetState extends State<_AddDependencySheet> {
  TaskData? _parentTask;
  TaskData? _childTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
            padding: const EdgeInsets.all(24),
            child: Text(
              'Tambah Ketergantungan',
              style: theme.textTheme.titleLarge,
            ),
          ),

          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppConstants.infoColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tugas anak hanya bisa dimulai setelah tugas induk selesai.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Task Selectors
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                final pendingTasks = state.tasks.where((t) => t.status != 2).toList()
                  ..sort((a, b) => a.priority.compareTo(b.priority));

                if (pendingTasks.length < 2) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Minimal 2 tugas aktif diperlukan',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Parent Task
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tugas Induk (Harus Selesai Duluan)',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<TaskData>(
                                value: _parentTask,
                                decoration: InputDecoration(
                                  hintText: 'Pilih tugas induk',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: pendingTasks
                                    .where((t) => t != _childTask)
                                    .map((task) {
                                  return DropdownMenuItem<TaskData>(
                                    value: task,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.flag,
                                          size: 16,
                                          color: _getPriorityColor(task.priority),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            task.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _parentTask = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Child Task
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tugas Anak (Menunggu Induk)',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<TaskData>(
                                value: _childTask,
                                decoration: InputDecoration(
                                  hintText: 'Pilih tugas anak',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: pendingTasks
                                    .where((t) => t != _parentTask)
                                    .map((task) {
                                  return DropdownMenuItem<TaskData>(
                                    value: task,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.flag,
                                          size: 16,
                                          color: _getPriorityColor(task.priority),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            task.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _childTask = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dependency Preview
                    if (_parentTask != null && _childTask != null) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppConstants.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppConstants.successColor.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(Icons.circle, size: 12, color: _getPriorityColor(_parentTask!.priority)),
                                        const SizedBox(height: 8),
                                        Text(_parentTask!.title, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(Icons.arrow_downward, color: AppConstants.successColor),
                                        const SizedBox(height: 8),
                                        Text('Selesai', style: theme.textTheme.bodySmall?.copyWith(color: AppConstants.successColor)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(Icons.circle, size: 12, color: _getPriorityColor(_childTask!.priority)),
                                        const SizedBox(height: 8),
                                        Text(_childTask!.title, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _parentTask != null && _childTask != null
                        ? () => _saveDependency(context)
                        : null,
                    child: const Text('Simpan'),
                  ),
                ),
              ],
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
        return AppConstants.priority3Color;
    }
  }

  void _saveDependency(BuildContext context) async {
    if (_parentTask == null || _childTask == null) return;

    // Add dependency to child task's labels
    final labels = _childTask!.labels ?? '';
    final depTag = 'dep:${_parentTask!.id}';

    // Check if dependency already exists
    if (labels.contains(depTag)) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ketergantungan sudah ada'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newLabels = labels.isEmpty ? depTag : '$labels,$depTag';

    // Update task using the bloc with UpdateTask event
    final bloc = context.read<TaskBloc>();
    final updatedTask = _childTask!.copyWith(labels: drift.Value(newLabels));
    bloc.add(UpdateTask(updatedTask));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ketergantungan berhasil ditambahkan'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Task with Dependency Data
class _TaskWithDependency {
  final String id;
  final TaskData task;
  final int priority;
  final List<TaskData> dependencies; // Tasks this depends on
  final List<TaskData> dependents; // Tasks that depend on this

  _TaskWithDependency({
    required this.id,
    required this.task,
    required this.priority,
    required this.dependencies,
    required this.dependents,
  });
}
