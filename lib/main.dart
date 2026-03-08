import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'features/tasks/bloc/task_bloc.dart';
import 'data/datasources/local/database.dart';

// Import BLoCs for new features
import 'features/timer/bloc/pomodoro_bloc.dart';
import 'features/voice/bloc/voice_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for DateFormat
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  // Initialize database - use different implementation for web
  final database = kIsWeb ? _createWebDatabase() : _createMobileDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        BlocProvider(create: (_) => TaskBloc(database: database)),
        BlocProvider(create: (_) => PomodoroBloc(database: database)),
        BlocProvider(create: (_) => VoiceBloc()),
      ],
      child: TaskFlowProApp(database: database),
    ),
  );
}

/// Create database for mobile platforms
AppDatabase _createMobileDatabase() {
  return AppDatabase(openConnection());
}

/// Create database for web (using in-memory for now)
/// In production, you'd use WebDatabase with proper setup
AppDatabase _createWebDatabase() {
  // For web, we use an in-memory database
  // Using a simple in-memory executor for web
  return AppDatabase(
    LazyDatabase(() async {
      return NativeDatabase.memory();
    }),
  );
}

class TaskFlowProApp extends StatefulWidget {
  final AppDatabase database;

  const TaskFlowProApp({super.key, required this.database});

  @override
  State<TaskFlowProApp> createState() => _TaskFlowProAppState();
}

class _TaskFlowProAppState extends State<TaskFlowProApp> {
  ThemeProvider? _themeProvider;
  bool _isListenerSet = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'TaskFlow Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set up listener only once
    if (!_isListenerSet) {
      _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      _themeProvider!.addListener(_onThemeChanged);
      _isListenerSet = true;
    }
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _themeProvider?.removeListener(_onThemeChanged);
    super.dispose();
  }
}
