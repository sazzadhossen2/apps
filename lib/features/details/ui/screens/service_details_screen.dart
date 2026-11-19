import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/kstrings.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/common_widgets.dart';
import '../../../../utils/widgets/kbutton.dart';
import '../../../../utils/widgets/ktext.dart';
import '../../../../utils/widgets/net_image.dart';
import '../../../../utils/widgets/state_views.dart';
import '../../../booking/ui/screens/booking_screen.dart';
import '../../../home/models/service_model.dart';
import '../../../home/ui/controller/home_controller.dart';
import '../../../reviews/ui/review_widgets.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({
    super.key,
    required this.serviceId,
    this.initial,
  });

  final String serviceId;

  /// Shown immediately while the full details load.
  final ServiceModel? initial;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  ServiceModel? _service;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = widget.initial;
    _loading = widget.initial == null;
    _load();
  }

  @override
  void didUpdateWidget(covariant ServiceDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceId != widget.serviceId) {
      _service = widget.initial;
      _loading = widget.initial == null;
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    if (_service == null) {
      setState(() => _loading = true);
    }
    final fresh = await context.read<HomeController>().fetchService(
      widget.serviceId,
    );
    if (!mounted) return;
    setState(() {
      if (fresh != null) _service = fresh;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _service;
    if (s == null) {
      return Scaffold(
        appBar: AppBar(),
        body: _loading
            ? const LoadingView()
            : ErrorView(
                message: 'We could not load this service.',
                onRetry: _load,
              ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: KColors.primary,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: KColors.navy,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetImage(url: s.image),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x66000000), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ResponsiveBody(
              maxWidth: 720,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconPill(
                          icon: Icons.category_rounded,
                          text: s.category,
                          color: KColors.primaryDark,
                          background: KColors.mint,
                        ),
                        if (s.isFeatured) ...[
                          const SizedBox(width: 8),
                          const IconPill(
                            icon: Icons.local_fire_department_rounded,
                            text: 'Featured',
                            color: KColors.pendingFg,
                            background: KColors.pendingBg,
                          ),
                        ],
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          color: KColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: 3),
                        KText(
                          text: s.rating.toStringAsFixed(1),
                          fontWeight: FontWeight.w800,
                        ),
                        KText(
                          text: '  (${s.reviewsCount} reviews · ${s.bookingsCount} bookings)',
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          color: KColors.textSecondary,

                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    KText(
                      text: s.name,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            icon: Icons.payments_rounded,
                            label: 'Price',
                            value: Fmt.price(s.price),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            icon: Icons.schedule_rounded,
                            label: 'Estimated duration',
                            value: Fmt.duration(s.durationMinutes),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionTitle(title: 'About this service'),
                    const SizedBox(height: 10),
                    KText(
                      text: s.description,
                      fontSize: 15,
                      color: KColors.textSecondary,
                      height: 1.55,
                    ),
                    const SizedBox(height: 22),
                    AppCard(
                      child: Column(
                        children: [
                          const InfoRow(
                            icon: Icons.access_time_filled_rounded,
                            label: 'Booking hours',
                            value: KStrings.workingHours,
                          ),
                          const Divider(),
                          const InfoRow(
                            icon: Icons.event_available_rounded,
                            label: 'Cancellation',
                            value: 'Free while your booking is pending',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    ReviewsSection(serviceId: s.id),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: KColors.surface,
          border: Border(top: BorderSide(color: KColors.border)),
        ),
        child: SafeArea(
          child: ResponsiveBody(
            maxWidth: 720,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KText(
                        text: 'Total',
                        fontSize: 12,
                        color: KColors.textSecondary,
                      ),
                      KText(
                        text: Fmt.price(s.price),
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: KColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: KButton(
                      label: 'Book now',
                      icon: Icons.calendar_month_rounded,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(service: s),
                        ),
                      ),
                    ),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KColors.mint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: KColors.primary, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KText(
                  text: label,
                  fontSize: 11.5,
                  color: KColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                KText(text: value, fontSize: 16, fontWeight: FontWeight.w800),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
