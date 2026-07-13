import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/processing/processing_screen.dart';
import '../screens/translation/translation_screen.dart';
import '../screens/projects/projects_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/project_detail/project_detail_screen.dart';
import '../screens/main_shell/main_shell.dart';

/// راوتر التطبيق
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // الشيل الرئيسي مع Bottom Navigation Bar
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/projects',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProjectsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // شاشات المعالجة (بدون Bottom Nav)
      GoRoute(
        path: '/processing/:projectId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return ProcessingScreen(
            projectId: projectId,
            extra: extra,
          );
        },
      ),

      GoRoute(
        path: '/translation/:projectId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return TranslationScreen(projectId: projectId);
        },
      ),

      GoRoute(
        path: '/project-detail/:projectId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final projectId = state.pathParameters['projectId']!;
          return ProjectDetailScreen(projectId: projectId);
        },
      ),
    ],
  );
}

/// أسماء المسارات
class AppRoutes {
  static const home = '/home';
  static const projects = '/projects';
  static const settings = '/settings';
  static String processing(String id) => '/processing/$id';
  static String translation(String id) => '/translation/$id';
  static String projectDetail(String id) => '/project-detail/$id';
}
