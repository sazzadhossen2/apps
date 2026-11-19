import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/resource.dart';
import '../../../../features/details/ui/screens/service_details_screen.dart';
import '../../../booking/ui/screens/booking_screen.dart';
import '../../../reviews/ui/review_widgets.dart';
import '../../models/appointment_model.dart';
import '../controller/my_bookings_controller.dart';
import '../../../../utils/widgets/widgets.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key, required this.appointment});

  /// Initial snapshot; the live version is read from the controller so status changes show instantly.
  final AppointmentModel appointment;

  Future<void> _cancel(BuildContext context, AppointmentModel a) async {
    final controller = context.read<MyBookingsController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: Text('${a.serviceName} on ${Fmt.date(a.startAt)} at ${Fmt.time(a.startAt)} will be cancelled and the time slot released.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Keep booking')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: KColors.danger),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await controller.cancel(a.id);
    AppSnack.show(ok ? 'Booking cancelled' : (controller.cancelError ?? 'Could not cancel the booking'), error: !ok);
  }

  Future<void> _pay(BuildContext context, AppointmentModel a) async {
    await context.read<MyBookingsController>().pay(a.id);
  }

  Future<void> _review(BuildContext context, AppointmentModel a) async {
    final controller = context.read<MyBookingsController>();
    final saved = await showReviewSheet(context, appointmentId: a.id, serviceName: a.serviceName);
    if (saved) controller.markReviewed(a.id);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<MyBookingsController>();
    final a = c.byId(appointment.id) ?? appointment;
    final cancelling = c.cancellingId == a.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: SingleChildScrollView(
        child: ResponsiveBody(
          maxWidth: 720,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  padding: const EdgeInsets.all(12),
                  onTap: a.service == null
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceDetailsScreen(serviceId: a.serviceId, initial: a.service))),
                  child: Row(
                    children: [
                      NetImage(url: a.service?.image ?? '', width: 72, height: 72, radius: 14),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KText(text: a.serviceName, fontSize: 17, fontWeight: FontWeight.w800, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            StatusChip(status: a.status),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: KColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      InfoRow(icon: Icons.calendar_today_rounded, label: 'Date', value: Fmt.date(a.startAt)),
                      InfoRow(icon: Icons.access_time_rounded, label: 'Time', value: '${Fmt.time(a.startAt)} – ${Fmt.time(a.endAt)}'),
                      InfoRow(icon: Icons.schedule_rounded, label: 'Duration', value: Fmt.duration(a.durationMinutes)),
                      InfoRow(icon: Icons.payments_rounded, label: 'Price', value: Fmt.price(a.price)),
                      InfoRow(icon: Icons.credit_card_rounded, label: 'Payment', value: PaymentStatus.label(a.paymentStatus)),
                      InfoRow(icon: Icons.confirmation_number_rounded, label: 'Booking ID', value: '#${a.shortId}'),
                      InfoRow(icon: Icons.history_toggle_off_rounded, label: 'Booked on', value: Fmt.dateTime(a.createdAt)),
                      if (a.notes.isNotEmpty) InfoRow(icon: Icons.sticky_note_2_rounded, label: 'Notes', value: a.notes),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (a.status == AppointmentStatus.cancelled && a.adminNote.isNotEmpty) ...[
                  _Notice(icon: Icons.info_outline_rounded, text: 'Reason: ${a.adminNote}', color: KColors.cancelledFg, background: KColors.cancelledBg),
                  const SizedBox(height: 12),
                ],
                if (a.paymentStatus == PaymentStatus.refunded) ...[
                  const _Notice(icon: Icons.undo_rounded, text: 'Your payment was refunded to your card.', color: KColors.completedFg, background: KColors.completedBg),
                  const SizedBox(height: 12),
                ],
                if (a.paymentStatus == PaymentStatus.refundFailed) ...[
                  const _Notice(icon: Icons.error_outline_rounded, text: 'Your refund needs manual processing. Our team will contact you.', color: KColors.cancelledFg, background: KColors.cancelledBg),
                  const SizedBox(height: 12),
                ],
                if (a.canPay) ...[
                  KButton(
                    label: 'Pay ${Fmt.price(a.price)} online',
                    icon: Icons.lock_rounded,
                    isLoading: c.payingId == a.id,
                    onPressed: () => _pay(context, a),
                  ),
                  const SizedBox(height: 10),
                ],
                if (a.isPending) ...[
                  KButton(
                    label: 'Cancel booking',
                    icon: Icons.cancel_outlined,
                    type: KButtonType.outline,
                    isLoading: cancelling,
                    onPressed: () => _cancel(context, a),
                  ),
                  const SizedBox(height: 10),
                  KText(
                    text: a.isPaid ? 'Only pending bookings can be cancelled. A paid booking is refunded automatically.' : 'Only pending bookings can be cancelled.',
                    fontSize: 12.5,
                    color: KColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ] else if (a.isConfirmed)
                  const _Notice(icon: Icons.verified_rounded, text: 'Your booking is confirmed. See you then!', color: KColors.confirmedFg, background: KColors.confirmedBg)
                else if (a.canReview)
                  KButton(label: 'Rate this service', icon: Icons.star_rounded, onPressed: () => _review(context, a))
                else ...[
                  if (a.isCompleted && a.reviewed)
                    const _Notice(icon: Icons.star_rounded, text: 'Thanks for reviewing this service!', color: KColors.completedFg, background: KColors.completedBg),
                  if (a.service != null) ...[
                    const SizedBox(height: 12),
                    KButton(
                      label: 'Book again',
                      icon: Icons.replay_rounded,
                      type: a.isCompleted ? KButtonType.outline : KButtonType.primary,
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookingScreen(service: a.service!))),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, required this.color, required this.background});
  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: KText(text: text, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
