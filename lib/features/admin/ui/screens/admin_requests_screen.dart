import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/widgets.dart';
import '../../../my_bookings/models/appointment_model.dart';
import '../controller/admin_controller.dart';
import '../widget/request_card.dart';

/// All customer bookings. The admin confirms, denies (with a reason) or completes them.
class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  static const _filters = <(String label, String? status)>[
    ('Pending', AppointmentStatus.pending),
    ('Confirmed', AppointmentStatus.confirmed),
    ('Completed', AppointmentStatus.completed),
    ('Cancelled', AppointmentStatus.cancelled),
    ('All', null),
  ];

  Future<void> _run(BuildContext context, AppointmentModel a, String status, {String reason = '', required String success}) async {
    final error = await context.read<AdminController>().setStatus(a.id, status, reason: reason);
    AppSnack.show(error ?? success, error: error != null);
  }

  Future<void> _deny(BuildContext context, AppointmentModel a) async {
    final reasonCtrl = TextEditingController();
    final isConfirmed = a.isConfirmed;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isConfirmed ? 'Cancel this booking?' : 'Deny this request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${a.customer?.name ?? 'The customer'} will be emailed.${a.isPaid ? ' Their online payment will be refunded.' : ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLength: 200,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Reason (optional), e.g. fully booked'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Back')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: KColors.danger),
            child: Text(isConfirmed ? 'Cancel booking' : 'Deny'),
          ),
        ],
      ),
    );
    final reason = reasonCtrl.text;
    reasonCtrl.dispose();
    if (confirmed != true || !context.mounted) return;
    await _run(context, a, AppointmentStatus.cancelled, reason: reason, success: isConfirmed ? 'Booking cancelled' : 'Request denied');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AdminController>();
    final side = Responsive.side(context, maxWidth: 760);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking requests')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(side, 8, side, 0),
            child: TextField(
              onChanged: c.setSearch,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(hintText: 'Search customer name or email', prefixIcon: Icon(Icons.search_rounded)),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: side, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (label, status) = _filters[i];
                final n = status == null ? c.allCount : (c.counts[status] ?? 0);
                return ChoiceChip(
                  label: Text('$label ($n)'),
                  selected: c.statusFilter == status,
                  onSelected: (_) => c.setStatusFilter(status),
                );
              },
            ),
          ),
          Expanded(child: _list(context, c, side)),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AdminController c, double side) {
    if (c.requestsState == ViewState.loading || c.requestsState == ViewState.idle) {
      return const LoadingView(message: 'Loading requests...');
    }
    if (c.requestsState == ViewState.error && c.requests.isEmpty) {
      return ErrorView(message: c.requestsError ?? 'Could not load requests.', onRetry: c.loadRequests);
    }

    return RefreshIndicator(
      color: KColors.primary,
      onRefresh: () => c.loadRequests(silent: true),
      child: c.requests.isEmpty
          ? LayoutBuilder(
              builder: (context, box) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: box.maxHeight,
                    child: EmptyView(
                      icon: Icons.inbox_rounded,
                      title: c.statusFilter == AppointmentStatus.pending ? 'No pending requests' : 'Nothing here',
                      subtitle: c.statusFilter == AppointmentStatus.pending ? 'New customer bookings will appear here.' : 'No bookings match this filter.',
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(side, 4, side, 24),
              itemCount: c.requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = c.requests[i];
                return RequestCard(
                  appointment: a,
                  busy: c.actingId == a.id,
                  onConfirm: () => _run(context, a, AppointmentStatus.confirmed, success: 'Booking confirmed. The customer was emailed.'),
                  onDeny: () => _deny(context, a),
                  onComplete: () => _run(context, a, AppointmentStatus.completed, success: 'Marked as completed'),
                );
              },
            ),
    );
  }
}
