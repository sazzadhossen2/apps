import 'package:flutter/material.dart';

/// Brand palette: fresh green (trust, growth) + deep navy (text) + warm amber accent.
class KColors {
  KColors._();

  // Brand
  static const Color primary = Color(0xFF3EB074);
  static const Color primaryLight = Color(0xFF67BE70);
  static const Color primaryDark = Color(0xFF1F8A55);
  static const List<Color> gradient = [primary, primaryLight];
  static const Color accent = Color(0xFFFFCA40);

  // Neutrals
  static const Color navy = Color(0xFF0C1D2E);
  static const Color background = Color(0xFFF6F9F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = navy;
  static const Color textSecondary = Color(0xFF748BA0);
  static const Color border = Color(0xFFE3ECEE);
  static const Color mint = Color(0xFFE6F6EE);

  // Feedback
  static const Color danger = Color(0xFFDD4B39);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Booking status colours (foreground / background)
  static const Color pendingFg = Color(0xFFB7791F);
  static const Color pendingBg = Color(0xFFFFF4D6);
  static const Color confirmedFg = primaryDark;
  static const Color confirmedBg = mint;
  static const Color cancelledFg = danger;
  static const Color cancelledBg = Color(0xFFFDECEA);
  static const Color completedFg = Color(0xFF2563EB);
  static const Color completedBg = Color(0xFFE8F0FE);
}
