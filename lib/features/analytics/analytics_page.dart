import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_constants.dart';
import '../tasks/bloc/task_bloc.dart';
import '../../models/task_category.dart';
import '../../data/datasources/local/database.dart';

/// Analytics Page
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Time period filter: 0 = this week, 1 = this month, 2 = all time
  int _timePeriod = 0;

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
                      'Analitik Produktivitas',
                      style: theme.textTheme.headlineLarge,
                    ),
                    DropdownButton<int>(
                      value: _timePeriod,
                      underline: const SizedBox(),
                      onChanged: (value) {
                        setState(() {
                          _timePeriod = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Minggu Ini')),
                        DropdownMenuItem(value: 1, child: Text('Bulan Ini')),
                        DropdownMenuItem(value: 2, child: Text('Semua')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    final tasks = _getTasksForPeriod(state.tasks);
                    final completed = tasks.where((t) => t.status == 2).length;
                    final totalHours = (completed * 0.5).toStringAsFixed(1); // Assume 30min per task

                    // Calculate streak
                    final streak = _calculateStreak(state.tasks);

                    return Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle,
                            label: 'Selesai',
                            value: '$completed',
                            color: AppConstants.successColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.schedule,
                            label: 'Estimasi Jam',
                            value: '${totalHours}h',
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department,
                            label: 'Streak',
                            value: '$streak hari',
                            color: AppConstants.warningColor,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Weekly Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    final weeklyData = _getWeeklyData(state.tasks);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Produktivitas Mingguan',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: weeklyData.values.isEmpty ? 10 : (weeklyData.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          const days = [
                                            'Sen',
                                            'Sel',
                                            'Rab',
                                            'Kam',
                                            'Jum',
                                            'Sab',
                                            'Min'
                                          ];
                                          return Text(
                                            days[value.toInt() % 7],
                                            style: theme.textTheme.bodySmall,
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value == 0) return const SizedBox();
                                          return Text(
                                            value.toInt().toString(),
                                            style: theme.textTheme.bodySmall,
                                          );
                                        },
                                        reservedSize: 30,
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: theme.dividerColor,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: weeklyData.entries.map((entry) {
                                    return _buildBarGroup(entry.key, entry.value.toDouble());
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Priority Distribution
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    final tasks = _getTasksForPeriod(state.tasks);
                    final p1Count = tasks.where((t) => t.priority == 1).length;
                    final p2Count = tasks.where((t) => t.priority == 2).length;
                    final p3Count = tasks.where((t) => t.priority == 3).length;
                    final p4Count = tasks.where((t) => t.priority == 4).length;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distribusi Prioritas',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 20),
                            _buildPriorityRow(context, 'P1 - Urgent', p1Count,
                                AppConstants.priority1Color),
                            const SizedBox(height: 12),
                            _buildPriorityRow(context, 'P2 - Tinggi', p2Count,
                                AppConstants.priority2Color),
                            const SizedBox(height: 12),
                            _buildPriorityRow(context, 'P3 - Normal', p3Count,
                                AppConstants.priority3Color),
                            const SizedBox(height: 12),
                            _buildPriorityRow(context, 'P4 - Rendah', p4Count,
                                AppConstants.priority4Color),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Category Breakdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    final tasks = _getTasksForPeriod(state.tasks);

                    // Count by category using labels
                    final categoryCount = <String, int>{};
                    for (final task in tasks) {
                      final labels = task.labels ?? '';
                      if (labels.isNotEmpty) {
                        final parts = labels.split(',');
                        for (final part in parts) {
                          final trimmed = part.trim();
                          categoryCount[trimmed] = (categoryCount[trimmed] ?? 0) + 1;
                        }
                      } else {
                        categoryCount['Tanpa Kategori'] = (categoryCount['Tanpa Kategori'] ?? 0) + 1;
                      }
                    }

                    if (categoryCount.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tugas per Kategori',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 20),
                            ...categoryCount.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildCategoryRow(
                                  context,
                                  entry.key,
                                  entry.value,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  List<TaskData> _getTasksForPeriod(List<TaskData> allTasks) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    if (_timePeriod == 0) {
      // This week
      final startOfWeek = startOfToday.subtract(Duration(days: now.weekday - 1));
      return allTasks.where((t) =>
        t.dueDate != null && t.dueDate!.isAfter(startOfWeek.subtract(const Duration(days: 1)))
      ).toList();
    } else if (_timePeriod == 1) {
      // This month
      final startOfMonth = DateTime(now.year, now.month, 1);
      return allTasks.where((t) =>
        t.dueDate != null && t.dueDate!.isAfter(startOfMonth.subtract(const Duration(days: 1))))
      .toList();
    } else {
      // All time
      return allTasks;
    }
  }

  Map<int, int> _getWeeklyData(List<TaskData> allTasks) {
    final now = DateTime.now();
    final data = <int, int>{0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (final task in allTasks) {
      if (task.dueDate != null && task.status == 2) {
        final diff = task.dueDate!.difference(now).inDays;
        final dayIndex = (now.weekday - 1 + diff) % 7;
        final adjustedIndex = (dayIndex < 0 ? dayIndex + 7 : dayIndex.toInt()) % 7;
        data[adjustedIndex] = (data[adjustedIndex] ?? 0) + 1;
      }
    }

    return data;
  }

  int _calculateStreak(List<TaskData> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;

    // Check backwards from today
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final hasCompletedTask = allTasks.any((t) =>
        t.status == 2 &&
        t.dueDate != null &&
        DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day).isAtSameMomentAs(checkDate));

      if (hasCompletedTask) {
        streak++;
      } else if (i > 0) {
        // Break streak if we're not checking today (allow for today to be incomplete)
        break;
      }
    }

    return streak;
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppConstants.primaryColor,
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildPriorityRow(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(
          count.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String category,
    int count,
  ) {
    final theme = Theme.of(context);

    // Find category color
    final catData = PredefinedCategories.all.where((c) => category.toLowerCase() == c.name.toLowerCase()).firstOrNull;
    final color = catData?.colorValue ?? AppConstants.primaryColor;

    return Row(
      children: [
        Text(
          catData?.icon ?? '📁',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(category, style: theme.textTheme.bodyMedium),
        ),
        Text(
          count.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
