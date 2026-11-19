import 'package:flutter/material.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/widgets.dart';
import '../../../my_bookings/models/appointment_model.dart';

/// One customer booking request with the actions the admin can take.
class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.appointment,
    required this.busy,
    required this.onConfirm,
    required this.onDeny,
    required this.onComplete,
  });

  final AppointmentModel appointment;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback onDeny;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final customer = a.customer;
    final started = !a.startAt.isAfter(DateTime.now());

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: KColors.mint,
                child: Text(
                  (customer?.name.isNotEmpty ?? false) ? customer!.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: KColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KText(text: customer?.name ?? 'Customer', fontWeight: FontWeight.w800, fontSize: 15.5, maxLines: 1, overflow: TextOverflow.ellipsis),
                    KText(
                      text: [if (customer != null) customer.email, if ((customer?.phone ?? '').isNotEmpty) customer!.phone].join(' · '),
                      fontSize: 12,
                      color: KColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusChip(status: a.status),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          Row(
            children: [
              NetImage(url: a.service?.image ?? '', width: 52, height: 52, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KText(text: a.serviceName, fontWeight: FontWeight.w700, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    KText(text: '${Fmt.date(a.startAt)}  ·  ${Fmt.time(a.startAt)} – ${Fmt.time(a.endAt)}', fontSize: 12.5, color: KColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              KText(text: Fmt.price(a.price), fontWeight: FontWeight.w800, color: KColors.primary, fontSize: 16),
              const SizedBox(width: 10),
              PaymentChip(status: a.paymentStatus),
              const Spacer(),
              KText(text: '#${a.shortId}', fontSize: 11.5, color: KColors.textSecondary),
            ],
          ),
          if (a.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: KColors.background, borderRadius: BorderRadius.circular(10)),
              child: KText(text: 'Customer note: ${a.notes}', fontSize: 12.5, color: KColors.textSecondary, height: 1.4),
            ),
          ],
          if (a.status == AppointmentStatus.cancelled && a.adminNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            KText(text: 'Reason: ${a.adminNote}', fontSize: 12.5, color: KColors.cancelledFg),
          ],
          if (a.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: KButton(label: 'Deny', type: KButtonType.outline, height: 44, onPressed: busy ? null : onDeny)),
                const SizedBox(width: 10),
                Expanded(child: KButton(label: 'Confirm', icon: Icons.check_rounded, height: 44, isLoading: busy, onPressed: onConfirm)),
              ],
            ),
          ] else if (a.isConfirmed) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: KButton(label: 'Cancel', type: KButtonType.outline, height: 44, onPressed: busy ? null : onDeny)),
                const SizedBox(width: 10),
                Expanded(
                  child: KButton(label: 'Mark completed', icon: Icons.task_alt_rounded, height: 44, isLoading: busy, onPressed: started ? onComplete : null),
                ),
              ],
            ),
            if (!started)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: KText(text: 'You can complete it once the appointment time has started.', fontSize: 11.5, color: KColors.textSecondary),
              ),
          ],
        ],
      ),
    );
  }
}
