import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/local/database.dart';
import '../../tasks/bloc/task_bloc.dart';

/// Pomodoro Timer State
class PomodoroState extends Equatable {
  final bool isRunning;
  final bool isPaused;
  final int currentSession;
  final int totalSessions;
  final int remainingSeconds;
  final PomodoroMode mode;
  final int? currentTaskId;

  const PomodoroState({
    this.isRunning = false,
    this.isPaused = false,
    this.currentSession = 1,
    this.totalSessions = 4,
    this.remainingSeconds = AppConstants.pomodoroWorkMinutes * 60,
    this.mode = PomodoroMode.work,
    this.currentTaskId,
  });

  PomodoroState copyWith({
    bool? isRunning,
    bool? isPaused,
    int? currentSession,
    int? totalSessions,
    int? remainingSeconds,
    PomodoroMode? mode,
    int? currentTaskId,
  }) {
    return PomodoroState(
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      currentSession: currentSession ?? this.currentSession,
      totalSessions: totalSessions ?? this.totalSessions,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      mode: mode ?? this.mode,
      currentTaskId: currentTaskId ?? this.currentTaskId,
    );
  }

  int get totalMinutes => remainingSeconds ~/ 60;
  int get totalSeconds => remainingSeconds % 60;

  String get formattedTime {
    final minutes = totalMinutes.toString().padLeft(2, '0');
    final seconds = totalSeconds.toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get progress {
    final totalSeconds = mode == PomodoroMode.work
        ? AppConstants.pomodoroWorkMinutes * 60
        : (mode == PomodoroMode.shortBreak
            ? AppConstants.pomodoroShortBreakMinutes * 60
            : AppConstants.pomodoroLongBreakMinutes * 60);
    return 1 - (remainingSeconds / totalSeconds);
  }

  @override
  List<Object?> get props => [
        isRunning,
        isPaused,
        currentSession,
        totalSessions,
        remainingSeconds,
        mode,
        currentTaskId
      ];
}

/// Pomodoro Mode
enum PomodoroMode {
  work,
  shortBreak,
  longBreak,
}

/// Pomodoro Events
abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();

  @override
  List<Object?> get props => [];
}

class PomodoroStart extends PomodoroEvent {
  final int? taskId;

  const PomodoroStart({this.taskId});
}

class PomodoroPause extends PomodoroEvent {}

class PomodoroResume extends PomodoroEvent {}

class PomodoroStop extends PomodoroEvent {}

class PomodoroReset extends PomodoroEvent {}

class PomodoroSkip extends PomodoroEvent {}

class PomodoroTick extends PomodoroEvent {}

class PomodoroSetTask extends PomodoroEvent {
  final int taskId;

  const PomodoroSetTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Pomodoro Timer Bloc
class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AppDatabase database;

  PomodoroBloc({required this.database}) : super(const PomodoroState()) {
    on<PomodoroStart>(_onStart);
    on<PomodoroPause>(_onPause);
    on<PomodoroResume>(_onResume);
    on<PomodoroStop>(_onStop);
    on<PomodoroReset>(_onReset);
    on<PomodoroSkip>(_onSkip);
    on<PomodoroTick>(_onTick);
    on<PomodoroSetTask>(_onSetTask);

    _initAudio();
  }

  void _initAudio() async {
    // You can add notification sounds here
    try {
      await _audioPlayer.setUrl('asset:///assets/sounds/notification.mp3');
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  Future<void> _onStart(PomodoroStart event, Emitter<PomodoroState> emit) async {
    if (state.isRunning) return;

    emit(state.copyWith(
      isRunning: true,
      isPaused: false,
      currentTaskId: event.taskId ?? state.currentTaskId,
    ));

    _startTimer();
  }

  Future<void> _onPause(PomodoroPause event, Emitter<PomodoroState> emit) async {
    if (!state.isRunning || state.isPaused) return;

    _timer?.cancel();
    emit(state.copyWith(isPaused: true));
  }

  Future<void> _onResume(
      PomodoroResume event, Emitter<PomodoroState> emit) async {
    if (!state.isRunning || !state.isPaused) return;

    emit(state.copyWith(isPaused: false));
    _startTimer();
  }

  Future<void> _onStop(PomodoroStop event, Emitter<PomodoroState> emit) async {
    _timer?.cancel();
    await _saveSession();

    emit(state.copyWith(
      isRunning: false,
      isPaused: false,
    ));
  }

  Future<void> _onReset(PomodoroReset event, Emitter<PomodoroState> emit) async {
    _timer?.cancel();

    emit(state.copyWith(
      isRunning: false,
      isPaused: false,
      currentSession: 1,
      remainingSeconds: AppConstants.pomodoroWorkMinutes * 60,
      mode: PomodoroMode.work,
    ));
  }

  Future<void> _onSkip(PomodoroSkip event, Emitter<PomodoroState> emit) async {
    await _saveSession();
    await _playNotificationSound();

    final nextMode = _getNextMode();
    final nextDuration = _getDurationForMode(nextMode);
    final nextSession = nextMode == PomodoroMode.work
        ? state.currentSession + 1
        : state.currentSession;

    emit(state.copyWith(
      mode: nextMode,
      remainingSeconds: nextDuration,
      currentSession: nextSession,
      isRunning: false,
      isPaused: false,
    ));
  }

  Future<void> _onTick(PomodoroTick event, Emitter<PomodoroState> emit) async {
    if (state.remainingSeconds > 0) {
      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
    } else {
      await _onSessionComplete(emit);
    }
  }

  Future<void> _onSetTask(
      PomodoroSetTask event, Emitter<PomodoroState> emit) async {
    emit(state.copyWith(currentTaskId: event.taskId));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(PomodoroTick());
    });
  }

  Future<void> _onSessionComplete(Emitter<PomodoroState> emit) async {
    _timer?.cancel();
    await _saveSession();
    await _playNotificationSound();

    final nextMode = _getNextMode();
    final nextDuration = _getDurationForMode(nextMode);
    final nextSession = nextMode == PomodoroMode.work
        ? state.currentSession + 1
        : state.currentSession;

    emit(state.copyWith(
      mode: nextMode,
      remainingSeconds: nextDuration,
      currentSession: nextSession,
      isRunning: false,
      isPaused: false,
    ));
  }

  PomodoroMode _getNextMode() {
    switch (state.mode) {
      case PomodoroMode.work:
        // Check if it's time for a long break
        if (state.currentSession >= AppConstants.pomodoroSessionsBeforeLongBreak) {
          return PomodoroMode.longBreak;
        }
        return PomodoroMode.shortBreak;
      case PomodoroMode.shortBreak:
      case PomodoroMode.longBreak:
        return PomodoroMode.work;
    }
  }

  int _getDurationForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.work:
        return AppConstants.pomodoroWorkMinutes * 60;
      case PomodoroMode.shortBreak:
        return AppConstants.pomodoroShortBreakMinutes * 60;
      case PomodoroMode.longBreak:
        return AppConstants.pomodoroLongBreakMinutes * 60;
    }
  }

  Future<void> _saveSession() async {
    // Only save work sessions
    if (state.mode == PomodoroMode.work && state.currentTaskId != null) {
      final duration = _getDurationForMode(state.mode) - state.remainingSeconds;

      try {
        await database.into(database.pomodoroSessions).insert(
          PomodoroSessionsCompanion.insert(
            taskId: state.currentTaskId!,
            duration: duration ~/ 60, // Convert to minutes
            startedAt: DateTime.now().subtract(Duration(seconds: duration)),
            completedAt: Value(DateTime.now()),
            isCompleted: const Value(true),
            type: const Value('work'),
          ),
        );
      } catch (e) {
        print('Error saving session: $e');
      }
    }
  }

  Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
