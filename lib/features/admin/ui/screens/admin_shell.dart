import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../profile/ui/screens/profile_screen.dart';
import '../controller/admin_controller.dart';
import 'admin_busy_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_requests_screen.dart';
import 'admin_services_screen.dart';

/// Home of the admin account: Dashboard · Requests · Busy · Services · Profile.
/// Customers never see this; the app picks it after login when `user.role == 'admin'`.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  /// Lets any admin screen switch tab (e.g. "review pending requests" on the dashboard).
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final Set<int> _opened = {0};

  @override
  void initState() {
    super.initState();
    AdminShell.tab.addListener(_onTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<AdminController>();
      c.loadStats();
      c.loadRequests(); // also feeds the badge on the Requests tab
    });
  }

  @override
  void dispose() {
    AdminShell.tab.removeListener(_onTab);
    super.dispose();
  }

  void _onTab() {
    if (!mounted) return;
    final c = context.read<AdminController>();
    final first = _opened.add(AdminShell.tab.value);
    switch (AdminShell.tab.value) {
      case 0:
        c.loadStats(silent: true);
      case 1:
        c.loadRequests(silent: true);
      case 2:
        c.loadBusy(silent: !first);
      case 3:
        c.loadServices(silent: !first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = context.select<AdminController, int>((c) => c.pendingCount);

    return ValueListenableBuilder<int>(
      valueListenable: AdminShell.tab,
      builder: (context, index, _) {
        return PopScope(
          canPop: index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) AdminShell.tab.value = 0;
          },
          child: Scaffold(
            body: IndexedStack(
              index: index,
              children: const [
                AdminDashboardScreen(),
                AdminRequestsScreen(),
                AdminBusyScreen(),
                AdminServicesScreen(),
                ProfileScreen(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => AdminShell.tab.value = i,
              destinations: [
                const NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Dashboard'),
                NavigationDestination(
                  icon: Badge(isLabelVisible: pending > 0, label: Text('$pending'), child: const Icon(Icons.inbox_outlined)),
                  selectedIcon: Badge(isLabelVisible: pending > 0, label: Text('$pending'), child: const Icon(Icons.inbox_rounded)),
                  label: 'Requests',
                ),
                const NavigationDestination(icon: Icon(Icons.event_busy_outlined), selectedIcon: Icon(Icons.event_busy_rounded), label: 'Busy'),
                const NavigationDestination(icon: Icon(Icons.design_services_outlined), selectedIcon: Icon(Icons.design_services_rounded), label: 'Services'),
                const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
            ),
          ),
        );
      },
    );
  }
}
