import 'package:flutter/material.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/ktext.dart';
import '../../../../utils/widgets/net_image.dart';
import '../../../../utils/widgets/state_views.dart';
import '../../models/appointment_model.dart';
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.appointment, required this.onTap});

  final AppointmentModel appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              NetImage(url: a.service?.image ?? '', width: 60, height: 60, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KText(text: a.serviceName, fontWeight: FontWeight.w700, fontSize: 15.5, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: KColors.textSecondary),
                        const SizedBox(width: 5),
                        Flexible(child: KText(text: Fmt.date(a.startAt), fontSize: 12.5, color: KColors.textSecondary, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 13, color: KColors.textSecondary),
                        const SizedBox(width: 5),
                        KText(text: Fmt.time(a.startAt), fontSize: 12.5, color: KColors.textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
          Row(
            children: [
              StatusChip(status: a.status),
              if (a.status != 'cancelled' || a.paymentStatus != 'unpaid') ...[
                const SizedBox(width: 8),
                PaymentChip(status: a.paymentStatus),
              ],
              const Spacer(),
              KText(text: Fmt.price(a.price), fontWeight: FontWeight.w800, color: KColors.primary, fontSize: 15),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: KColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
