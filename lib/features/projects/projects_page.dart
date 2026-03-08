import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/constants/app_constants.dart';
import '../tasks/bloc/task_bloc.dart';
import '../../data/datasources/local/database.dart';

/// Projects Page
class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
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
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Proyek',
                      style: theme.textTheme.headlineLarge,
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _showAddProjectDialog(context),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Baru'),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Access Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akses Cepat',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            icon: Icons.view_kanban,
                            label: 'Kanban',
                            color: '#6366F1',
                            onTap: () => context.push('/projects/kanban'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            icon: Icons.dashboard_customize,
                            label: 'Template',
                            color: '#8B5CF6',
                            onTap: () => context.push('/projects/templates'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickAccessCard(
                            context,
                            icon: Icons.account_tree,
                            label: 'Dependensi',
                            color: '#EC4899',
                            onTap: () => context.push('/projects/dependencies'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Projects Grid from Categories
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                // Get unique labels as "projects"
                final projectMap = <String, List<TaskData>>{};
                for (final task in state.tasks) {
                  final labels = task.labels ?? 'Uncategorized';
                  final parts = labels.split(',');
                  for (final part in parts) {
                    final trimmed = part.trim();
                    if (trimmed.startsWith('template:')) continue; // Skip template tags
                    if (trimmed.startsWith('dep:')) continue; // Skip dependency tags
                    if (trimmed.isEmpty) continue;

                    projectMap.putIfAbsent(trimmed, () => []);
                    projectMap[trimmed]!.add(task);
                  }
                }

                // Default projects if empty
                if (projectMap.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_off_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada proyek',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _showAddProjectDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Buat Proyek'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final projectName = projectMap.keys.elementAt(index);
                        final tasks = projectMap[projectName]!;
                        final completedTasks = tasks.where((t) => t.status == 2).length;
                        final progress = tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

                        return _buildProjectCard(
                          context,
                          name: projectName,
                          taskCount: tasks.length,
                          completedCount: completedTasks,
                          progress: progress,
                          tasks: tasks,
                        );
                      },
                      childCount: projectMap.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cardColor = _colorFromHex(color);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor.withOpacity(0.15),
              cardColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cardColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: cardColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cardColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context, {
    required String name,
    required int taskCount,
    required int completedCount,
    required double progress,
    required List<TaskData> tasks,
  }) {
    final theme = Theme.of(context);
    final projectColor = _getColorForProject(name);

    return GestureDetector(
      onTap: () => _showProjectDetail(context, name, tasks),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon & Name
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: projectColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.folder_outlined,
                      color: projectColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Task count
              Text(
                '$completedCount dari $taskCount tugas',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 12),

              // Progress bar
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: projectColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectDetail(BuildContext context, String projectName, List<TaskData> tasks) {
    final theme = Theme.of(context);
    final completedTasks = tasks.where((t) => t.status == 2).toList();
    final pendingTasks = tasks.where((t) => t.status != 2).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectName,
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          '${completedTasks.length}/${tasks.length} tugas selesai',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildTab(context, 'Pending', pendingTasks.length, true),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Selesai', completedTasks.length, false),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tasks List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final isCompleted = task.status == 2;

                  return ListTile(
                    leading: Checkbox(
                      value: isCompleted,
                      onChanged: (_) {
                        context.read<TaskBloc>().add(
                          ToggleTaskStatus(task.id, isCompleted ? 1 : 2),
                        );
                        Navigator.pop(context);
                      },
                      activeColor: AppConstants.successColor,
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : null,
                      ),
                    ),
                    subtitle: task.description != null && task.description!.isNotEmpty
                        ? Text(task.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    trailing: Icon(
                      Icons.flag,
                      size: 16,
                      color: _getPriorityColor(task.priority),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, int count, bool isActive) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppConstants.primaryColor : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppConstants.primaryColor : theme.dividerColor,
        ),
      ),
      child: Text(
        '$label $count',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isActive ? Colors.white : theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buat Kategori Proyek'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Text(
              'Catatan: Proyek dibuat otomatis dari kategori tugas',
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama kategori tidak boleh kosong'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Create a sample task with this category
              final bloc = context.read<TaskBloc>();
              final task = TasksCompanion.insert(
                title: 'Tugas sample untuk ${nameController.text.trim()}',
                priority: const drift.Value(3),
                status: const drift.Value(1),
                dueDate: drift.Value(DateTime.now()),
                createdAt: drift.Value(DateTime.now()),
                labels: drift.Value(nameController.text.trim()),
              );
              bloc.add(AddTask(task));

              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kategori "${nameController.text.trim()}" berhasil dibuat dengan tugas sample'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Buat'),
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

  Color _getColorForProject(String projectName) {
    // Generate consistent color based on project name
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF6366F1),
    ];
    final index = projectName.hashCode.abs() % colors.length;
    return colors[index];
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
}
