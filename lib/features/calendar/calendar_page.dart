import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/constants/app_constants.dart';
import '../tasks/bloc/task_bloc.dart';
import 'package:drift/drift.dart' hide Column;

/// Calendar Page
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Load all tasks when calendar page opens
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
          IconButton(
            icon: Icon(_calendarFormat == CalendarFormat.month
                ? Icons.view_week
                : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Widget
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(
                  color: AppConstants.errorColor.withOpacity(0.7),
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: theme.textTheme.titleLarge ?? const TextStyle(),
                leftChevronIcon: const Icon(Icons.chevron_left),
                rightChevronIcon: const Icon(Icons.chevron_right),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: theme.textTheme.bodySmall!,
                weekendStyle: theme.textTheme.bodySmall!.copyWith(
                  color: AppConstants.errorColor.withOpacity(0.7),
                ),
              ),
            ),
          ),

          // Selected Date Tasks
          Expanded(
            child: _selectedDay == null
                ? _buildEmptyState(context)
                : _buildTasksForDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Pilih tanggal untuk melihat tugas',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksForDate(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // Get tasks for the selected date
        final selectedDate = _selectedDay!;
        final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        final tasksForDate = state.tasks.where((task) {
          final dueDate = task.dueDate;
          if (dueDate == null) return false;
          return dueDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                 dueDate.isBefore(endOfDay);
        }).toList();

        // Sort by priority
        tasksForDate.sort((a, b) => a.priority.compareTo(b.priority));

        if (tasksForDate.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_alt_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada tugas untuk tanggal ini',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateIndonesian(selectedDate),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tasksForDate.length} tugas dijadwalkan',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: tasksForDate.length,
                itemBuilder: (context, index) {
                  final task = tasksForDate[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      title: Text(task.title),
                      subtitle: Text(
                        'P${task.priority} • ${_formatTime(task.dueDate!)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (task.status != 2)
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline),
                              onPressed: () {
                                context.read<TaskBloc>().add(
                                  ToggleTaskStatus(task.id, 2),
                                );
                              },
                            )
                          else
                            const Icon(Icons.check_circle, color: Colors.green),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              _confirmDeleteTask(context, task.id);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _showTaskDetail(context, task);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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
      default:
        return AppConstants.priority4Color;
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateIndonesian(DateTime date) {
    const dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    final dayName = dayNames[date.weekday - 1];
    final monthName = monthNames[date.month - 1];

    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  void _showTaskDetail(BuildContext context, task) {
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
              Text('Deadline: ${_formatDateIndonesian(task.dueDate)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
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

  void _confirmDeleteTask(BuildContext context, int taskId) {
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
}
