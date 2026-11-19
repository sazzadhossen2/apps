import 'package:flutter/material.dart';

import '../../app/kcolor.dart';
enum KButtonType { primary, outline, danger }

class KButton extends StatelessWidget {
  const KButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = KButtonType.primary,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final KButtonType type;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(14);
    final filled = type != KButtonType.outline;
    final fg = filled ? Colors.white : (type == KButtonType.danger ? KColors.danger : KColors.primary);

    final content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );

    BoxDecoration decoration;
    switch (type) {
      case KButtonType.primary:
        decoration = BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(colors: KColors.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: KColors.primary.withValues(alpha: 0.28), blurRadius: 14, offset: const Offset(0, 6))],
        );
      case KButtonType.danger:
        decoration = BoxDecoration(borderRadius: radius, color: KColors.danger);
      case KButtonType.outline:
        decoration = BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: type == KButtonType.outline ? KColors.primary : KColors.danger, width: 1.4),
        );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: DecoratedBox(
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: enabled ? onPressed : null,
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
