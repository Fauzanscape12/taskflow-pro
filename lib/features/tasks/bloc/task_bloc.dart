import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:drift/drift.dart';

import '../../../data/datasources/local/database.dart';

/// Task State
class TaskState extends Equatable {
  final List<TaskData> tasks;
  final List<TaskData> todayTasks;
  final List<TaskData> upcomingTasks;
  final List<TaskData> allTasks;
  final bool isLoading;
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.todayTasks = const [],
    this.upcomingTasks = const [],
    this.allTasks = const [],
    this.isLoading = false,
    this.error,
  });

  TaskState copyWith({
    List<TaskData>? tasks,
    List<TaskData>? todayTasks,
    List<TaskData>? upcomingTasks,
    List<TaskData>? allTasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      todayTasks: todayTasks ?? this.todayTasks,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      allTasks: allTasks ?? this.allTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [tasks, todayTasks, upcomingTasks, allTasks, isLoading, error];
}

/// Task Events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class LoadTodayTasks extends TaskEvent {}

class LoadUpcomingTasks extends TaskEvent {}

class LoadAllTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TasksCompanion task;

  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskData task;

  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final int taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskStatus extends TaskEvent {
  final int taskId;
  final int newStatus;

  const ToggleTaskStatus(this.taskId, this.newStatus);

  @override
  List<Object?> get props => [taskId, newStatus];
}

class AddPomodoroSession extends TaskEvent {
  final PomodoroSessionsCompanion session;

  const AddPomodoroSession(this.session);

  @override
  List<Object?> get props => [session];
}

/// Task Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final AppDatabase database;

  TaskBloc({required this.database}) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadTodayTasks>(_onLoadTodayTasks);
    on<LoadUpcomingTasks>(_onLoadUpcomingTasks);
    on<LoadAllTasks>(_onLoadAllTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
    on<AddPomodoroSession>(_onAddPomodoroSession);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final tasks = await database.getAllTasks();
      emit(state.copyWith(tasks: tasks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onLoadTodayTasks(
      LoadTodayTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final todayTasks = await database.getTodayTasks();
      emit(state.copyWith(todayTasks: todayTasks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onLoadUpcomingTasks(
      LoadUpcomingTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final upcomingTasks = await database.getUpcomingTasks();
      emit(state.copyWith(upcomingTasks: upcomingTasks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onLoadAllTasks(
      LoadAllTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final allTasks = await database.getAllTasks();
      emit(state.copyWith(allTasks: allTasks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await database.into(database.tasks).insert(event.task);
      add(LoadTasks());
      add(LoadTodayTasks());
      add(LoadAllTasks());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await database.updateTask(event.task);
      add(LoadTasks());
      add(LoadTodayTasks());
      add(LoadAllTasks());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await database.deleteTask(event.taskId);
      add(LoadTasks());
      add(LoadTodayTasks());
      add(LoadAllTasks());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onToggleTaskStatus(
      ToggleTaskStatus event, Emitter<TaskState> emit) async {
    try {
      final task = await database.getTask(event.taskId);
      if (task != null) {
        final updatedTask = task.copyWith(
          status: event.newStatus,
          completedAt: event.newStatus == 2
              ? Value(DateTime.now())
              : const Value(null),
        );
        await database.updateTask(updatedTask);
        add(LoadTasks());
        add(LoadTodayTasks());
        add(LoadAllTasks());
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAddPomodoroSession(
      AddPomodoroSession event, Emitter<TaskState> emit) async {
    try {
      await database.into(database.pomodoroSessions).insert(event.session);
      // Update task spent minutes
      final sessions = await database.getSessionsForTask(
          event.session.taskId.value);
      final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.duration);
      final task = await database.getTask(event.session.taskId.value);
      if (task != null) {
        await database.updateTask(
            task.copyWith(spentMinutes: totalMinutes));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
