import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/kstrings.dart';
import '../../../../app/utils.dart';
import '../../../../core/services/network/network_response.dart';
import '../../../../utils/widgets/widgets.dart';
import '../../../my_bookings/models/appointment_model.dart';
import '../../../my_bookings/ui/controller/my_bookings_controller.dart';
import '../../../navigation_menu/ui/screens/main_shell.dart';
import '../../../payment/payment_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key, required this.appointment});
  final AppointmentModel appointment;

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late AppointmentModel _a = widget.appointment;
  bool _paying = false;

  void _goHome(BuildContext context, int tab) {
    MainShell.tab.value = tab;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _pay() async {
    final bookings = context.read<MyBookingsController>();
    setState(() => _paying = true);
    final paid = await PaymentFlow.run(_a.id);
    if (!mounted) return;
    setState(() {
      _paying = false;
      if (paid != null) _a = paid;
    });
    if (paid != null) bookings.load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final a = _a;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context, 0);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ResponsiveBody(
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.elasticOut,
                      builder: (_, v, child) => Transform.scale(scale: v, child: child),
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: KColors.gradient)),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 60),
                      ),
                    ),
                    const SizedBox(height: 24),
                    KText(text: 'Booking received!', fontSize: 26, fontWeight: FontWeight.w800),
                    const SizedBox(height: 8),
                    KText(
                      text: 'Your request was sent and is waiting for confirmation. You can pay now or later from My Bookings.',
                      textAlign: TextAlign.center,
                      color: KColors.textSecondary,
                      height: 1.45,
                    ),
                    const SizedBox(height: 26),
                    AppCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: KText(text: a.serviceName, fontWeight: FontWeight.w800, fontSize: 17)),
                              StatusChip(status: a.status),
                            ],
                          ),
                          const Divider(height: 24),
                          InfoRow(icon: Icons.calendar_today_rounded, label: 'Date', value: Fmt.date(a.startAt)),
                          InfoRow(icon: Icons.access_time_rounded, label: 'Time', value: '${Fmt.time(a.startAt)} – ${Fmt.time(a.endAt)}'),
                          InfoRow(icon: Icons.payments_rounded, label: 'Price', value: Fmt.price(a.price)),
                          InfoRow(icon: Icons.credit_card_rounded, label: 'Payment', value: PaymentStatus.label(a.paymentStatus)),
                          InfoRow(icon: Icons.confirmation_number_rounded, label: 'Booking ID', value: '#${a.shortId}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (a.canPay) ...[
                      KButton(label: 'Pay ${Fmt.price(a.price)} now', icon: Icons.lock_rounded, isLoading: _paying, onPressed: _pay),
                      const SizedBox(height: 12),
                    ],
                    KButton(label: 'View my bookings', icon: Icons.event_note_rounded, type: a.canPay ? KButtonType.outline : KButtonType.primary, onPressed: () => _goHome(context, 1)),
                    const SizedBox(height: 12),
                    KButton(label: 'Back to home', type: KButtonType.outline, onPressed: () => _goHome(context, 0)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
