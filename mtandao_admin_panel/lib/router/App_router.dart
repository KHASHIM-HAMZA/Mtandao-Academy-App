import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtandao_admin_panel/components/admin_layout.dart';
import 'package:mtandao_admin_panel/pages/dashboard/dashboard.dart';
import 'package:mtandao_admin_panel/pages/login/login_page.dart';

// Temporary placeholder pages - we'll build these in Phase 2
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Users Management - Coming Soon'));
}

class TeachersPage extends StatelessWidget {
  const TeachersPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Teachers Management - Coming Soon'));
}

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Resources Manager - Coming Soon'));
}

class PastPapersPage extends StatelessWidget {
  const PastPapersPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Past Papers - Coming Soon'));
}

class CorrectionsPage extends StatelessWidget {
  const CorrectionsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Corrections - Coming Soon'));
}

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Subscriptions - Coming Soon'));
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Support Tickets - Coming Soon'));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Settings - Coming Soon'));
}

class AppRouter {
  late final GoRouter router = GoRouter(
    errorBuilder:
        (context, state) =>
            const Scaffold(body: Center(child: Text('Page not found!'))),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder:
            (context, state) => const MaterialPage(child: AdminLoginPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            pageBuilder:
                (context, state) => const MaterialPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/users',
            name: 'users',
            pageBuilder:
                (context, state) => const MaterialPage(child: UsersPage()),
          ),
          GoRoute(
            path: '/teachers',
            name: 'teachers',
            pageBuilder:
                (context, state) => const MaterialPage(child: TeachersPage()),
          ),
          GoRoute(
            path: '/resources',
            name: 'resources',
            pageBuilder:
                (context, state) => const MaterialPage(child: ResourcesPage()),
          ),
          GoRoute(
            path: '/pastpapers',
            name: 'pastpapers',
            pageBuilder:
                (context, state) => const MaterialPage(child: PastPapersPage()),
          ),
          GoRoute(
            path: '/corrections',
            name: 'corrections',
            pageBuilder:
                (context, state) =>
                    const MaterialPage(child: CorrectionsPage()),
          ),
          GoRoute(
            path: '/subscriptions',
            name: 'subscriptions',
            pageBuilder:
                (context, state) =>
                    const MaterialPage(child: SubscriptionsPage()),
          ),
          GoRoute(
            path: '/support',
            name: 'support',
            pageBuilder:
                (context, state) => const MaterialPage(child: SupportPage()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder:
                (context, state) => const MaterialPage(child: SettingsPage()),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = true; // Replace with actual auth check
      final goingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !goingToLogin) {
        return '/login';
      }

      if (isLoggedIn && goingToLogin) {
        return '/';
      }

      return null;
    },
  );
}
