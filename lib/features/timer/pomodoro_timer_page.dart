import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'bloc/pomodoro_bloc.dart';
import '../../core/constants/app_constants.dart';

/// Pomodoro Timer Page
class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PomodoroBloc, PomodoroState>(
          builder: (context, state) {
            return Column(
              children: [
                // Header
                _buildHeader(context, state),

                // Timer Display
                Expanded(
                  child: Center(
                    child: _buildTimerDisplay(context, state),
                  ),
                ),

                // Session Indicator
                _buildSessionIndicator(context, state),

                // Controls
                _buildControls(context, state),

                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PomodoroState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pomodoro Timer',
            style: theme.textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, PomodoroState state) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          // Background Circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getModeColor(state.mode).withOpacity(0.1),
            ),
          ),

          // Progress Circle
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: state.progress,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(_getModeColor(state.mode)),
            ),
          ),

          // Timer Text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.formattedTime,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: _getModeColor(state.mode),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getModeLabel(state.mode),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _getModeColor(state.mode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat()).fadeIn();
  }

  Widget _buildSessionIndicator(BuildContext context, PomodoroState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            'Sesi ${state.currentSession} dari ${state.totalSessions}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              state.totalSessions,
              (index) => Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < state.currentSession
                      ? _getModeColor(state.mode)
                      : theme.dividerColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, PomodoroState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset Button
          _buildControlButton(
            context,
            icon: Icons.refresh,
            label: 'Reset',
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            onTap: () => context.read<PomodoroBloc>().add(PomodoroReset()),
          ),

          // Main Action Button
          _buildMainControlButton(context, state),

          // Skip Button
          _buildControlButton(
            context,
            icon: Icons.skip_next,
            label: 'Skip',
            color: AppConstants.accentColor,
            onTap: () => context.read<PomodoroBloc>().add(PomodoroSkip()),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainControlButton(BuildContext context, PomodoroState state) {
    final theme = Theme.of(context);

    final isRunning = state.isRunning && !state.isPaused;
    final icon = isRunning
        ? Icons.pause
        : (state.isPaused ? Icons.play_arrow : Icons.play_arrow);
    final label = isRunning ? 'Pause' : (state.isPaused ? 'Lanjut' : 'Mulai');

    return GestureDetector(
      onTap: () {
        if (isRunning) {
          context.read<PomodoroBloc>().add(PomodoroPause());
        } else if (state.isPaused) {
          context.read<PomodoroBloc>().add(PomodoroResume());
        } else {
          context.read<PomodoroBloc>().add(const PomodoroStart());
        }
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getModeColor(state.mode),
              boxShadow: [
                BoxShadow(
                  color: _getModeColor(state.mode).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _getModeColor(state.mode),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildSettingsSheet(context),
    );
  }

  Widget _buildSettingsSheet(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Pengaturan Pomodoro',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Work Duration
              _buildSettingRow(
                context,
                icon: Icons.work,
                label: 'Durasi Kerja',
                value: '${AppConstants.pomodoroWorkMinutes} menit',
              ),

              const SizedBox(height: 16),

              // Short Break
              _buildSettingRow(
                context,
                icon: Icons.coffee,
                label: 'Istirahat Pendek',
                value: '${AppConstants.pomodoroShortBreakMinutes} menit',
              ),

              const SizedBox(height: 16),

              // Long Break
              _buildSettingRow(
                context,
                icon: Icons.weekend,
                label: 'Istirahat Panjang',
                value: '${AppConstants.pomodoroLongBreakMinutes} menit',
              ),

              const SizedBox(height: 16),

              // Sessions before Long Break
              _buildSettingRow(
                context,
                icon: Icons.calendar_today,
                label: 'Sesi Sebelum Istirahat Panjang',
                value: '${AppConstants.pomodoroSessionsBeforeLongBreak} sesi',
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getModeColor(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.work:
        return AppConstants.primaryColor;
      case PomodoroMode.shortBreak:
        return AppConstants.successColor;
      case PomodoroMode.longBreak:
        return AppConstants.infoColor;
    }
  }

  String _getModeLabel(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.work:
        return 'Fokus Kerja';
      case PomodoroMode.shortBreak:
        return 'Istirahat Pendek';
      case PomodoroMode.longBreak:
        return 'Istirahat Panjang';
    }
  }
}
