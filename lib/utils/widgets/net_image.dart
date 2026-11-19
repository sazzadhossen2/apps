import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/kcolor.dart';



/// Cached network image with a branded placeholder / error state.
class NetImage extends StatelessWidget {
  const NetImage({super.key, required this.url, this.width, this.height, this.radius = 0, this.fit = BoxFit.cover});

  final String url;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  Widget _placeholder({bool loading = false}) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [KColors.mint, Color(0xFFD3EFE0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: KColors.primary))
              : const Icon(Icons.spa_rounded, color: KColors.primary, size: 30),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url.isEmpty
          ? _placeholder()
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              placeholder: (_, __) => _placeholder(loading: true),
              errorWidget: (_, __, ___) => _placeholder(),
            ),
    );
  }
}
