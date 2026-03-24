import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/user_mgmt_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/tasks/wbs_screen.dart';
import '../../features/gantt_kanban/gantt_screen.dart';
import '../../features/gantt_kanban/kanban_screen.dart';
import '../../features/resources/resources_screen.dart';
import '../../shared/widgets/app_shell.dart';

// ── Routes ────────────────────────────────────────────────────────────────────

class AppRoutes {
  static const login      = '/login';
  static const dashboard  = '/dashboard';
  static const wbs        = '/projects/:projectId/wbs';
  static const gantt      = '/projects/:projectId/gantt';
  static const kanban     = '/projects/:projectId/kanban';
  static const resources  = '/resources';
  static const users      = '/admin/users';
}

// ── Router Provider ───────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      if (!isLoggedIn && !isLoginRoute) return AppRoutes.login;
      if (isLoggedIn && isLoginRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => _fade(const DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.wbs,
            pageBuilder: (context, state) => _fade(
              WbsScreen(projectId: state.pathParameters['projectId']!),
            ),
          ),
          GoRoute(
            path: AppRoutes.gantt,
            pageBuilder: (context, state) => _fade(
              GanttScreen(projectId: state.pathParameters['projectId']!),
            ),
          ),
          GoRoute(
            path: AppRoutes.kanban,
            pageBuilder: (context, state) => _fade(
              KanbanScreen(projectId: state.pathParameters['projectId']!),
            ),
          ),
          GoRoute(
            path: AppRoutes.resources,
            pageBuilder: (context, state) => _fade(const ResourcesScreen()),
          ),
          GoRoute(
            path: AppRoutes.users,
            pageBuilder: (context, state) => _fade(const UserMgmtScreen()),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _fade(Widget child) => CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
    );
