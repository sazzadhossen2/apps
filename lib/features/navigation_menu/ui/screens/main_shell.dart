import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../ai_assistant/ui/screens/ai_assistant_screen.dart';
import '../../../home/ui/screens/home_screen.dart';
import '../../../my_bookings/ui/controller/my_bookings_controller.dart';
import '../../../my_bookings/ui/screens/my_bookings_screen.dart';
import '../../../profile/ui/screens/profile_screen.dart';


/// Bottom navigation host: Home · Bookings · Assistant · Profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Lets any screen switch tabs (e.g. "View my bookings" after booking).
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    MainShell.tab.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    MainShell.tab.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (MainShell.tab.value == 1 && mounted) {
      context.read<MyBookingsController>().load(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: MainShell.tab,
      builder: (context, index, _) {
        return PopScope(
          canPop: index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) MainShell.tab.value = 0; // back goes to Home first, then exits
          },
          child: Scaffold(
            body: IndexedStack(
              index: index,
              children: const [HomeScreen(), MyBookingsScreen(), AiAssistantScreen(), ProfileScreen()],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => MainShell.tab.value = i,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note_rounded), label: 'Bookings'),
                NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome_rounded), label: 'Assistant'),
                NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
            ),
          ),
        );
      },
    );
  }
}
