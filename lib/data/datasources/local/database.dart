import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

/// Tasks Table
@DataClassName('TaskData')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(3))(); // 1-4
  IntColumn get status => integer().withDefault(const Constant(0))(); // 0=todo,1=inProgress,2=completed
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  IntColumn get duration => integer().nullable()(); // in minutes
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringPattern => text().nullable()(); // daily, weekly, etc.
  IntColumn get parentId => integer().nullable().references(Tasks, #id)(); // For subtasks
  TextColumn get labels => text().nullable()(); // Comma-separated labels
  IntColumn get order => integer().withDefault(const Constant(0))();
  TextColumn get voiceNote => text().nullable()(); // Path to voice note file
  IntColumn get estimatedMinutes => integer().nullable()();
  IntColumn get spentMinutes => integer().withDefault(const Constant(0))();
}

/// Projects Table
@DataClassName('ProjectData')
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().withDefault(const Constant('#6366F1'))();
  IntColumn get icon => integer().nullable()(); // Icon code point
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  IntColumn get order => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get viewMode => text().withDefault(const Constant('list'))(); // list, board, calendar
}

/// Pomodoro Sessions Table
@DataClassName('PomodoroSessionData')
class PomodoroSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  IntColumn get duration => integer()(); // in minutes
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(const Constant('work'))(); // work, shortBreak, longBreak
}

/// Categories/Labels Table
@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get color => text()();
  IntColumn get icon => integer().nullable()();
  IntColumn get order => integer().withDefault(const Constant(0))();
}

/// App Database
@DriftDatabase(tables: [Tasks, Projects, PomodoroSessions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // Queries
  Future<List<TaskData>> getAllTasks() => select(tasks).get();
  Future<List<TaskData>> getTasksByStatus(int status) =>
      (select(tasks)..where((t) => t.status.equals(status))).get();
  Future<List<TaskData>> getTasksByProject(int projectId) =>
      (select(tasks)..where((t) => t.projectId.equals(projectId))).get();
  Future<List<TaskData>> getTodayTasks() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(tasks)
          ..where((t) => t.dueDate.isBiggerOrEqualValue(startOfDay))
          ..where((t) => t.dueDate.isSmallerThanValue(endOfDay)))
        .get();
  }

  Future<List<TaskData>> getUpcomingTasks({int days = 7}) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return (select(tasks)
          ..where((t) => t.dueDate.isBiggerThanValue(now))
          ..where((t) => t.dueDate.isSmallerThanValue(future))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  Future<List<ProjectData>> getAllProjects() => select(projects).get();
  Future<List<ProjectData>> getActiveProjects() =>
      (select(projects)..where((p) => p.isArchived.equals(false))).get();

  Future<List<PomodoroSessionData>> getSessionsForTask(int taskId) =>
      (select(pomodoroSessions)..where((s) => s.taskId.equals(taskId))).get();
  Future<int> getTotalSpentMinutes(int taskId) =>
      (select(pomodoroSessions)
            ..where((s) => s.taskId.equals(taskId))
            ..where((s) => s.isCompleted.equals(true)))
          .get()
          .then((sessions) => sessions.fold<int>(
              0, (sum, s) => sum + s.duration));

  Future<List<CategoryData>> getAllCategories() => select(categories).get();

  // CRUD Helper Methods
  Future<TaskData?> getTask(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<bool> updateTask(TaskData task) => update(tasks).replace(task);
  Future<int> deleteTask(int id) =>
      (delete(tasks)..where((t) => t.id.equals(id))).go();

  Future<bool> updateProject(ProjectData project) =>
      update(projects).replace(project);
  Future<int> deleteProject(int id) =>
      (delete(projects)..where((p) => p.id.equals(id))).go();
}

/// Open database connection for mobile platforms
LazyDatabase openConnection() {
  // Use in-memory database for development
  // For production, use SQLite file
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'taskflow_pro.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
