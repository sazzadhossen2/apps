import 'package:flutter/material.dart';

import 'kcolor.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: KColors.primary).copyWith(
      primary: KColors.primary,
      onPrimary: Colors.white,
      secondary: KColors.accent,
      onSecondary: KColors.navy,
      surface: KColors.surface,
      onSurface: KColors.textPrimary,
      error: KColors.danger,
      outline: KColors.border,
    );
    final base = ThemeData.light(useMaterial3: true);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    Color navColor(Set<WidgetState> s) =>
        s.contains(WidgetState.selected) ? KColors.primary : KColors.textSecondary;

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: KColors.background,
      textTheme: base.textTheme.apply(bodyColor: KColors.textPrimary, displayColor: KColors.textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: KColors.background,
        foregroundColor: KColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: KColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: KColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: KColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: KColors.textSecondary, fontSize: 14),
        border: border(KColors.border),
        enabledBorder: border(KColors.border),
        focusedBorder: border(KColors.primary, 1.6),
        errorBorder: border(KColors.danger),
        focusedErrorBorder: border(KColors.danger, 1.6),
        errorStyle: const TextStyle(color: KColors.danger, fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: KColors.primary.withValues(alpha: 0.14),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: navColor(s),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(color: navColor(s), size: 24)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: KColors.primary,
        unselectedLabelColor: KColors.textSecondary,
        indicatorColor: KColors.primary,
        dividerColor: KColors.border,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: KColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dividerTheme: const DividerThemeData(color: KColors.border, thickness: 1, space: 1),
    );
  }
}
