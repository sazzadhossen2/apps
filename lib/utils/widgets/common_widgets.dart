import 'package:flutter/material.dart';

import '../../app/kcolor.dart';
import '../../app/utils.dart';

/// White rounded card with a soft border.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: color ?? KColors.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(borderRadius: radius, border: Border.all(color: KColors.border)),
          child: child,
        ),
      ),
    );
  }
}

/// Pill showing Pending / Confirmed / Cancelled / Completed.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    late final Color fg;
    late final Color bg;
    switch (status) {
      case AppointmentStatus.confirmed:
        fg = KColors.confirmedFg;
        bg = KColors.confirmedBg;
      case AppointmentStatus.cancelled:
        fg = KColors.cancelledFg;
        bg = KColors.cancelledBg;
      case AppointmentStatus.completed:
        fg = KColors.completedFg;
        bg = KColors.completedBg;
      default:
        fg = KColors.pendingFg;
        bg = KColors.pendingBg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            AppointmentStatus.label(status),
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: KColors.textPrimary)),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Icon + label + value row.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: KColors.mint, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 19, color: KColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: KColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: KColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Centers content and caps its width on tablets / landscape.
// class ResponsiveBody extends StatelessWidget {
//   const ResponsiveBody({super.key, required this.child, this.maxWidth = 560});
//   final Widget child;
//   final double maxWidth;
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topCenter,
//       child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
//     );
//   }
// }

/// Centers content and caps its width on tablets / landscape.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({super.key, required this.child, this.maxWidth = 560});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
    );
  }
}

/// Small rounded label with icon (duration, rating...).
class IconPill extends StatelessWidget {
  const IconPill({super.key, required this.icon, required this.text, this.color = KColors.textSecondary, this.background});
  final IconData icon;
  final String text;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background ?? KColors.background, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

/// Small pill for the payment state (Paid / Unpaid / Refunded).
class PaymentChip extends StatelessWidget {
  const PaymentChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg, IconData icon) = switch (status) {
      PaymentStatus.paid => (KColors.confirmedFg, KColors.confirmedBg, Icons.check_circle_rounded),
      PaymentStatus.refunded => (KColors.completedFg, KColors.completedBg, Icons.undo_rounded),
      PaymentStatus.refundFailed => (KColors.cancelledFg, KColors.cancelledBg, Icons.error_outline_rounded),
      _ => (KColors.textSecondary, KColors.background, Icons.payments_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: fg.withValues(alpha: 0.25))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(PaymentStatus.label(status), style: TextStyle(color: fg, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
