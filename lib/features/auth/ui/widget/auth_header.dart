import 'package:flutter/material.dart';

import '../../../../app/kcolor.dart';

/// Gradient header shared by Login and Register.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, top + 36, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [KColors.primaryDark, KColors.primary, KColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15, height: 1.35)),
            ],
          ),
        ),
      ),
    );
  }
}
