import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/state_views.dart';
import '../../../navigation_menu/ui/screens/main_shell.dart';
import '../../models/appointment_model.dart';
import '../controller/my_bookings_controller.dart';
import '../widget/booking_card.dart';
import 'booking_details_screen.dart';


class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<MyBookingsController>().load());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<MyBookingsController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My bookings'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Upcoming (${c.upcoming.length})'),
              Tab(text: 'Previous (${c.past.length})'),
            ],
          ),
        ),
        body: _buildBody(c),
      ),
    );
  }

  Widget _buildBody(MyBookingsController c) {
    if ((c.state == ViewState.loading || c.state == ViewState.idle) && c.upcoming.isEmpty && c.past.isEmpty) {
      return const LoadingView(message: 'Loading your bookings...');
    }
    if (c.state == ViewState.error && c.upcoming.isEmpty && c.past.isEmpty) {
      return ErrorView(message: c.error ?? 'Could not load your bookings.', onRetry: c.load);
    }
    return TabBarView(
      children: [
        _BookingList(
          items: c.upcoming,
          onRefresh: () => c.load(silent: true),
          emptyIcon: Icons.event_available_rounded,
          emptyTitle: 'No upcoming bookings',
          emptySubtitle: 'Book a service and it will show up here.',
          actionLabel: 'Browse services',
          onAction: () => MainShell.tab.value = 0,
        ),
        _BookingList(
          items: c.past,
          onRefresh: () => c.load(silent: true),
          emptyIcon: Icons.history_rounded,
          emptyTitle: 'No previous bookings',
          emptySubtitle: 'Completed and cancelled bookings appear here.',
        ),
      ],
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.items,
    required this.onRefresh,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.actionLabel,
    this.onAction,
  });

  final List<AppointmentModel> items;
  final Future<void> Function() onRefresh;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final side = Responsive.side(context, maxWidth: 760);
    return RefreshIndicator(
      color: KColors.primary,
      onRefresh: onRefresh,
      child: items.isEmpty
          ? LayoutBuilder(
              builder: (context, box) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: box.maxHeight,
                    child: EmptyView(icon: emptyIcon, title: emptyTitle, subtitle: emptySubtitle, actionLabel: actionLabel, onAction: onAction),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(side, 16, side, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => BookingCard(
                appointment: items[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookingDetailsScreen(appointment: items[i])),
                ),
              ),
            ),
    );
  }
}
