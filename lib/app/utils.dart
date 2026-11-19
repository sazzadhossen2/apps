import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'kcolor.dart';

enum ViewState { idle, loading, success, error }

class AppointmentStatus {
  AppointmentStatus._();
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';
  static const String completed = 'completed';

  static String label(String s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}';
}

class PaymentStatus {
  PaymentStatus._();
  static const String unpaid = 'unpaid';
  static const String paid = 'paid';
  static const String refunded = 'refunded';
  static const String refundFailed = 'refund_failed';

  static String label(String s) => switch (s) {
        paid => 'Paid',
        refunded => 'Refunded',
        refundFailed => 'Refund pending',
        _ => 'Unpaid',
      };
}

class Fmt {
  Fmt._();
  static final NumberFormat _money = NumberFormat('#,##0');

  static String price(num v) => '৳${_money.format(v)}';

  static String duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  static String date(DateTime d) => DateFormat('EEE, d MMM yyyy').format(d);
  static String time(DateTime d) => DateFormat('h:mm a').format(d);
  static String dateTime(DateTime d) => DateFormat('d MMM yyyy, h:mm a').format(d);
  static String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  static String weekday(DateTime d) => DateFormat('EEE').format(d);
  static String day(DateTime d) => DateFormat('d').format(d);
  static String month(DateTime d) => DateFormat('MMM').format(d);
  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);
  static String ym(DateTime d) => DateFormat('yyyy-MM').format(d);
  static String shortMonth(String ym) => DateFormat('MMM').format(DateTime.parse('$ym-01'));
  static String hm(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class Validators {
  Validators._();

  static String? required(String? v, [String label = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email address';
  }

  /// Same rule as the backend: 8+ characters, at least one letter and one number.
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v)) return 'Password must contain a letter';
    if (!RegExp(r'\d').hasMatch(v)) return 'Password must contain a number';
    return null;
  }

  static String? Function(String?) confirmPassword(TextEditingController other) => (v) {
        if (v == null || v.isEmpty) return 'Please confirm your password';
        if (v != other.text) return 'Passwords do not match';
        return null;
      };

  /// Optional field.
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return RegExp(r'^\+?[0-9\s-]{7,16}$').hasMatch(v.trim()) ? null : 'Enter a valid phone number';
  }
}

/// Global snackbar helper (works from controllers and after awaits, no BuildContext needed).
class AppSnack {
  AppSnack._();
  static final GlobalKey<ScaffoldMessengerState> key = GlobalKey<ScaffoldMessengerState>();

  static void show(String message, {bool error = false}) {
    key.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          backgroundColor: error ? KColors.danger : KColors.navy,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }
}

class Responsive {
  Responsive._();

  /// Horizontal padding that keeps content at most [maxWidth] wide and centred on tablets.
  static double side(BuildContext context, {double maxWidth = 1000, double min = 16}) {
    final w = MediaQuery.sizeOf(context).width;
    final extra = (w - maxWidth) / 2;
    return extra > min ? extra : min;
  }
}
