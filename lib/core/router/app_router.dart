import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/all_tasks/all_tasks_page.dart';
import '../../features/home/home_page.dart';
import '../../features/calendar/calendar_page.dart';
import '../../features/projects/projects_page.dart';
import '../../features/analytics/analytics_page.dart';
import '../../features/settings/settings_page.dart';

// New feature pages
import '../../features/timer/pomodoro_timer_page.dart';
import '../../features/voice/voice_command_page.dart';
import '../../features/kanban/kanban_board_page.dart';
import '../../features/templates/project_templates_page.dart';
import '../../features/task_dependencies/task_dependencies_page.dart';
import '../../features/categories/categories_page.dart';

/// App Router Configuration
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/all',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(
            navigationShell: navigationShell,
          );
        },
        branches: [
          // All Tasks Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/all',
                name: 'all',
                builder: (context, state) => const AllTasksPage(),
              ),
            ],
          ),
          // Home / Today Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomePage(),
                routes: [
                  // Timer Page
                  GoRoute(
                    path: 'timer',
                    name: 'timer',
                    builder: (context, state) => const PomodoroTimerPage(),
                  ),
                  // Voice Command Page
                  GoRoute(
                    path: 'voice',
                    name: 'voice',
                    builder: (context, state) => const VoiceCommandPage(),
                  ),
                  // Categories Page
                  GoRoute(
                    path: 'categories',
                    name: 'categories',
                    builder: (context, state) => const CategoriesPage(),
                  ),
                ],
              ),
            ],
          ),

          // Calendar Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                name: 'calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),

          // Projects Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/projects',
                name: 'projects',
                builder: (context, state) => const ProjectsPage(),
                routes: [
                  // Kanban Board Page
                  GoRoute(
                    path: 'kanban',
                    name: 'kanban',
                    builder: (context, state) => const KanbanBoardPage(),
                  ),
                  // Project Templates Page
                  GoRoute(
                    path: 'templates',
                    name: 'templates',
                    builder: (context, state) => const ProjectTemplatesPage(),
                  ),
                  // Task Dependencies Page
                  GoRoute(
                    path: 'dependencies',
                    name: 'dependencies',
                    builder: (context, state) => const TaskDependenciesPage(),
                  ),
                ],
              ),
            ],
          ),

          // Analytics Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                name: 'analytics',
                builder: (context, state) => const AnalyticsPage(),
              ),
            ],
          ),

          // Settings Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Main Page with Bottom Navigation
class MainPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'All',
          ),
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
