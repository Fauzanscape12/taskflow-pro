import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/datasources/local/database.dart';
import '../../core/constants/app_constants.dart';

/// Task Card Widget
class TaskCard extends StatelessWidget {
  final TaskData task;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
  });

  Color get _priorityColor {
    switch (task.priority) {
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

  bool get _isCompleted => task.status == 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(task.id.toString()),
      onDismissed: (_) => onDelete(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe to delete
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe to complete
          onComplete();
          return false;
        }
        return false;
      },
      background: _buildSwipeBackground(context, true),
      secondaryBackground: _buildSwipeBackground(context, false),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isCompleted
                  ? Colors.transparent
                  : _priorityColor.withOpacity(0.3),
              width: _isCompleted ? 0 : 2,
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              _buildCheckbox(context),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: _isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: _isCompleted
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Meta info
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (task.dueDate != null) _buildDueDateChip(context),
                        if (task.projectId != null) _buildProjectChip(context),
                        if (task.labels != null && task.labels!.isNotEmpty)
                          _buildLabelChip(context),
                        if (task.estimatedMinutes != null)
                          _buildTimeChip(context),
                      ],
                    ),
                  ],
                ),
              ),

              // Priority indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? theme.dividerColor
                      : _priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideX(),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onComplete,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isCompleted
                ? theme.colorScheme.primary
                : theme.dividerColor,
            width: 2,
          ),
          color: _isCompleted
              ? theme.colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: _isCompleted
            ? Icon(
                Icons.check,
                size: 14,
                color: theme.colorScheme.primary,
              )
            : null,
      ),
    );
  }

  Widget _buildDueDateChip(BuildContext context) {
    final theme = Theme.of(context);
    final dueDate = task.dueDate!;
    final now = DateTime.now();
    final isOverdue = dueDate.isBefore(now) && !_isCompleted;
    final isToday = dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;

    String timeText;
    if (isToday) {
      timeText = 'Hari ini';
    } else if (dueDate.difference(now).inDays == 1) {
      timeText = 'Besok';
    } else {
      timeText = '${dueDate.day} ${_getMonthName(dueDate.month)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppConstants.errorColor.withOpacity(0.1)
            : theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: isOverdue
                ? AppConstants.errorColor
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            timeText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isOverdue
                  ? AppConstants.errorColor
                  : theme.colorScheme.primary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectChip(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 12,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            'Project',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelChip(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label_outline,
            size: 12,
            color: AppConstants.accentColor,
          ),
          const SizedBox(width: 4),
          Text(
            task.labels!.split(',').first,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppConstants.accentColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(BuildContext context) {
    final theme = Theme.of(context);
    final hours = (task.estimatedMinutes! / 60).floor();
    final minutes = task.estimatedMinutes! % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 12,
            color: AppConstants.infoColor,
          ),
          const SizedBox(width: 4),
          Text(
            hours > 0 ? '${hours}j ${minutes}m' : '${minutes}m',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppConstants.infoColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, bool isLeft) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isLeft
            ? AppConstants.successColor
            : AppConstants.errorColor,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Icon(
        isLeft ? Icons.check : Icons.delete,
        color: Colors.white,
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }
}
