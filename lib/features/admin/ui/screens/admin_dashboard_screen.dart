import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/widgets.dart';
import '../../../reviews/ui/review_widgets.dart';
import '../../models/admin_models.dart';
import '../controller/admin_controller.dart';
import 'admin_shell.dart';

/// Monthly overview: bookings per status, completed, reviews, rating and online revenue.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AdminController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: _body(context, c),
    );
  }

  Widget _body(BuildContext context, AdminController c) {
    final stats = c.stats;
    if (stats == null) {
      if (c.statsState == ViewState.error) return ErrorView(message: c.statsError ?? 'Could not load statistics.', onRetry: c.loadStats);
      return const LoadingView(message: 'Loading dashboard...');
    }

    final side = Responsive.side(context, maxWidth: 900);
    final s = stats.summary;
    return RefreshIndicator(
      color: KColors.primary,
      onRefresh: () => c.loadStats(silent: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(side, 8, side, 28),
        children: [
          _MonthSwitcher(controller: c),
          const SizedBox(height: 14),
          if (stats.pendingRequests > 0) ...[
            AppCard(
              color: KColors.pendingBg,
              onTap: () => AdminShell.tab.value = 1,
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: KColors.pendingFg),
                  const SizedBox(width: 12),
                  Expanded(child: KText(text: '${stats.pendingRequests} booking request${stats.pendingRequests == 1 ? '' : 's'} waiting for your decision', color: KColors.pendingFg, fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right_rounded, color: KColors.pendingFg),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          GridView.extent(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            maxCrossAxisExtent: 210,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              _StatTile(icon: Icons.event_note_rounded, label: 'Total bookings', value: '${s.total}', color: KColors.navy),
              _StatTile(icon: Icons.task_alt_rounded, label: 'Completed', value: '${s.completed}', color: KColors.completedFg),
              _StatTile(icon: Icons.hourglass_top_rounded, label: 'Pending', value: '${s.pending}', color: KColors.pendingFg),
              _StatTile(icon: Icons.verified_rounded, label: 'Confirmed', value: '${s.confirmed}', color: KColors.confirmedFg),
              _StatTile(icon: Icons.cancel_rounded, label: 'Cancelled / denied', value: '${s.cancelled}', color: KColors.cancelledFg),
              _StatTile(icon: Icons.rate_review_rounded, label: 'Reviews', value: '${s.reviews}', color: KColors.primary),
              _StatTile(icon: Icons.star_rounded, label: 'Average rating', value: s.reviews == 0 ? '–' : s.avgRating.toStringAsFixed(1), color: KColors.warning),
              _StatTile(icon: Icons.payments_rounded, label: 'Paid online', value: Fmt.price(s.revenue), color: KColors.primaryDark),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Last 6 months'),
          const SizedBox(height: 10),
          _TrendChart(points: stats.series, selected: stats.month),
          if (stats.topServices.isNotEmpty) ...[
            const SizedBox(height: 22),
            const SectionTitle(title: 'Top services this month'),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  for (var i = 0; i < stats.topServices.length; i++) ...[
                    if (i > 0) const Divider(height: 18),
                    Row(
                      children: [
                        CircleAvatar(radius: 13, backgroundColor: KColors.mint, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: KColors.primaryDark))),
                        const SizedBox(width: 10),
                        Expanded(child: KText(text: stats.topServices[i].name, fontWeight: FontWeight.w600, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        KText(text: '${stats.topServices[i].bookings} bookings', color: KColors.textSecondary, fontSize: 12.5),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          SectionTitle(title: 'Reviews in ${Fmt.monthYear(c.month)} (${c.reviews.length})'),
          const SizedBox(height: 10),
          if (c.reviews.isEmpty)
            AppCard(child: KText(text: 'No reviews were written this month.', color: KColors.textSecondary))
          else
            for (final r in c.reviews) ReviewTile(review: r, showService: true),
          const SizedBox(height: 8),
          KText(
            text: 'Bookings are counted by their appointment date; reviews by the day they were written. Revenue counts bookings paid online.',
            fontSize: 11.5,
            color: KColors.textSecondary,
            height: 1.4,
          ),
        ],
      ),
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          IconButton(onPressed: () => controller.changeMonth(-1), icon: const Icon(Icons.chevron_left_rounded), tooltip: 'Previous month'),
          Expanded(
            child: Center(
              child: KText(text: Fmt.monthYear(controller.month), fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: controller.isCurrentMonth ? null : () => controller.changeMonth(1),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 19),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: KText(text: value, fontSize: 22, fontWeight: FontWeight.w800)),
              KText(text: label, fontSize: 12, color: KColors.textSecondary, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple bar chart (no extra package): total vs completed bookings per month.
class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.points, required this.selected});
  final List<MonthPoint> points;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<int>(1, (m, p) => p.total > m ? p.total : m);
    const chartHeight = 130.0;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      child: Column(
        children: [
          SizedBox(
            height: chartHeight + 22,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final p in points)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        KText(text: '${p.completed}/${p.total}', fontSize: 11, color: KColors.textSecondary),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _Bar(height: chartHeight * p.total / maxValue, color: p.month == selected ? KColors.primaryLight.withValues(alpha: 0.55) : KColors.border),
                            const SizedBox(width: 3),
                            _Bar(height: chartHeight * p.completed / maxValue, color: p.month == selected ? KColors.primary : KColors.primary.withValues(alpha: 0.45)),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final p in points)
                Expanded(
                  child: Column(
                    children: [
                      KText(text: Fmt.shortMonth(p.month), fontSize: 12, fontWeight: p.month == selected ? FontWeight.w800 : FontWeight.w500, color: p.month == selected ? KColors.textPrimary : KColors.textSecondary),
                      KText(text: '${p.reviews} rev.', fontSize: 10.5, color: KColors.textSecondary),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: KColors.border, text: 'All bookings'),
              SizedBox(width: 16),
              _Legend(color: KColors.primary, text: 'Completed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        width: 14,
        height: height < 3 ? 3 : height,
        decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
      );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          KText(text: text, fontSize: 11.5, color: KColors.textSecondary),
        ],
      );
}
