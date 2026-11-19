import 'package:flutter/material.dart';
import '../../../../utils/widgets/common_widgets.dart';

import '../../../../app/kcolor.dart';
import '../../../../app/utils.dart';
import '../../../../utils/widgets/ktext.dart';
import '../../../../utils/widgets/net_image.dart';
import '../../models/service_model.dart';

/// Horizontal list card: image, name, description, price, duration.
class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, required this.onTap});

  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Row(
        children: [
          NetImage(url: service.image, width: 92, height: 92, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: KText(text: service.name, fontSize: 15.5, fontWeight: FontWeight.w700, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (service.rating > 0) ...[
                          const Icon(Icons.star_rounded, size: 16, color: KColors.accent),
                          const SizedBox(width: 2),
                          KText(text: service.rating.toStringAsFixed(1), fontSize: 12.5, fontWeight: FontWeight.w700),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    KText(
                      text: service.description,
                      fontSize: 12,
                      color: KColors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    KText(text: Fmt.price(service.price), fontSize: 16, fontWeight: FontWeight.w800, color: KColors.primary),
                    const Spacer(),
                    IconPill(icon: Icons.schedule_rounded, text: Fmt.duration(service.durationMinutes)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Large image card used in the "Featured" carousel.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({super.key, required this.service, required this.onTap});

  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 250,
          child: Stack(
            fit: StackFit.expand,
            children: [
              NetImage(url: service.image),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xCC0C1D2E)],
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: KColors.accent, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Featured', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: KColors.navy)),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KText(text: service.name, color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: KColors.accent),
                        const SizedBox(width: 3),
                        KText(text: service.rating.toStringAsFixed(1), color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                        const Spacer(),
                        KText(text: Fmt.price(service.price), color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
