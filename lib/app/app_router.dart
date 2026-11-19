import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/admin/ui/screens/admin_shell.dart';
import '../features/auth/ui/controller/auth_controller.dart';
import '../features/auth/ui/screens/login_screen.dart';
import '../features/navigation_menu/ui/screens/main_shell.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Navigation that must work without a BuildContext (e.g. when the session expires).
class AppRouter {
  AppRouter._();

  static void resetToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  /// Customers land in the booking app, admins in the admin panel.
  static void resetToHome() {
    final ctx = navigatorKey.currentContext;
    final isAdmin = ctx != null && ctx.read<AuthController>().isAdmin;
    MainShell.tab.value = 0;
    AdminShell.tab.value = 0;
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => isAdmin ? const AdminShell() : const MainShell()),
      (_) => false,
    );
  }
}
