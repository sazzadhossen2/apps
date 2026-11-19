import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/input_field.dart';
import '../../../../utils/widgets/kbutton.dart';
import '../../../../utils/widgets/ktext.dart';
import '../../../../utils/widgets/net_image.dart';
import '../../../../utils/widgets/state_views.dart';
import '../../../home/models/service_model.dart';
import '../../../my_bookings/ui/controller/my_bookings_controller.dart';
import '../../models/slot_model.dart';
import '../controller/booking_controller.dart';
import 'booking_confirmation_screen.dart';



class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.service});
  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookingController>(
      create: (_) => BookingController(service),
      child: const _BookingView(),
    );
  }
}

class _BookingView extends StatefulWidget {
  const _BookingView();

  @override
  State<_BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<_BookingView> {
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    final c = context.read<BookingController>();
    final myBookings = context.read<MyBookingsController>();
    c.notes = _notes.text;

    final appointment = await c.submit();
    if (!mounted) return;

    if (appointment == null) {
      AppSnack.show(c.submitError ?? 'Could not complete the booking.', error: true);
      return;
    }
    myBookings.load(silent: true);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BookingConfirmationScreen(appointment: appointment)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BookingController>();
    final today = DateUtils.dateOnly(DateTime.now());
    final dates = List.generate(14, (i) => DateTime(today.year, today.month, today.day + i));
    final slot = c.selectedSlot;

    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ResponsiveBody(
          maxWidth: 720,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service summary
                AppCard(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      NetImage(url: c.service.image, width: 64, height: 64, radius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KText(text: c.service.name, fontWeight: FontWeight.w700, fontSize: 15.5, maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            KText(text: '${Fmt.price(c.service.price)}  •  ${Fmt.duration(c.service.durationMinutes)}', color: KColors.textSecondary, fontSize: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Date strip
                const SectionTitle(title: 'Select date'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _DateTile(date: dates[i], selected: dates[i] == c.selectedDate, onTap: () => c.selectDate(dates[i])),
                  ),
                ),
                const SizedBox(height: 24),

                // Slots
                SectionTitle(
                  title: 'Available time',
                  trailing: KText(text: Fmt.date(c.selectedDate), fontSize: 12.5, color: KColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _SlotsSection(controller: c),
                const SizedBox(height: 8),
                const _Legend(),
                const SizedBox(height: 24),

                // Notes
                InputFieldText(
                  controller: _notes,
                  label: 'Notes (optional)',
                  hint: 'Anything the provider should know?',
                  icon: Icons.edit_note_rounded,
                  maxLines: 3,
                  maxLength: 300,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: KColors.surface, border: Border(top: BorderSide(color: KColors.border))),
        child: SafeArea(
          child: ResponsiveBody(
            maxWidth: 720,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (slot != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available_rounded, size: 18, color: KColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: KText(
                              text: '${Fmt.date(slot.startLocal)}  •  ${Fmt.time(slot.startLocal)}',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          KText(text: Fmt.price(c.service.price), fontWeight: FontWeight.w800, color: KColors.primary),
                        ],
                      ),
                    ),
                  KButton(
                    label: slot == null ? 'Select a time slot' : 'Confirm booking',
                    icon: slot == null ? null : Icons.check_circle_rounded,
                    isLoading: c.submitting,
                    onPressed: slot == null ? null : _confirm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, required this.selected, required this.onTap});
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : KColors.textPrimary;
    final sub = selected ? Colors.white.withValues(alpha: 0.85) : KColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 62,
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(colors: KColors.gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter) : null,
          color: selected ? null : KColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? KColors.primary : KColors.border),
          boxShadow: selected ? [BoxShadow(color: KColors.primary.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(Fmt.weekday(date), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sub)),
            const SizedBox(height: 4),
            Text(Fmt.day(date), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg)),
            const SizedBox(height: 2),
            Text(Fmt.month(date), style: TextStyle(fontSize: 11.5, color: sub)),
          ],
        ),
      ),
    );
  }
}

class _SlotsSection extends StatelessWidget {
  const _SlotsSection({required this.controller});
  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c.slotsState == ViewState.loading) {
      return const SizedBox(height: 140, child: LoadingView());
    }
    if (c.slotsState == ViewState.error) {
      return SizedBox(height: 240, child: ErrorView(title: 'Could not load time slots', message: c.slotsError ?? 'Please try again.', onRetry: c.loadSlots));
    }
    if (c.slots.isEmpty) {
      return const SizedBox(
        height: 200,
        child: EmptyView(icon: Icons.event_busy_rounded, title: 'No time slots for this day', subtitle: 'Please pick another date.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (c.allBooked)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: KColors.pendingBg, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: KColors.pendingFg, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: KText(text: 'Fully booked on this day. Try another date.', color: KColors.pendingFg, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        LayoutBuilder(
          builder: (context, box) {
            final cols = box.maxWidth >= 480 ? 4 : 3;
            final w = (box.maxWidth - (cols - 1) * 10) / cols;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in c.slots)
                  _SlotChip(
                    width: w,
                    slot: s,
                    selected: c.selectedSlot?.startAtUtc == s.startAtUtc,
                    onTap: () => c.selectSlot(s),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.width, required this.slot, required this.selected, required this.onTap});
  final double width;
  final SlotModel slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final available = slot.available;
    final Color bg = selected ? KColors.primary : (available ? KColors.surface : KColors.background);
    final Color fg = selected ? Colors.white : (available ? KColors.textPrimary : KColors.textSecondary.withValues(alpha: 0.6));
    return Semantics(
      button: true,
      enabled: available,
      label: '${Fmt.time(slot.startLocal)} ${available ? 'available' : (slot.reason == 'busy' ? 'unavailable' : 'booked')}',
      child: GestureDetector(
        onTap: available ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: width,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? KColors.primary : (available ? KColors.border : Colors.transparent)),
          ),
          child: Text(
            Fmt.time(slot.startLocal),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: fg,
              decoration: available ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget dot(Color color, String text, {bool border = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4), border: border ? Border.all(color: KColors.border) : null),
            ),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(fontSize: 12, color: KColors.textSecondary)),
          ],
        );
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        dot(KColors.surface, 'Available', border: true),
        dot(KColors.primary, 'Selected'),
        dot(KColors.border, 'Booked / past'),
      ],
    );
  }
}
