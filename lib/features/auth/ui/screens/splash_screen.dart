import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../app/app_router.dart';
import '../../../../app/kcolor.dart';
import '../../../../app/kstrings.dart';
import '../controller/auth_controller.dart';

/// Restores the saved session, then routes to Home or Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final auth = context.read<AuthController>();
    final loggedIn = await auth.bootstrap();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    loggedIn ? AppRouter.resetToHome() : AppRouter.resetToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [KColors.primaryDark, KColors.primary, KColors.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.event_available_rounded, size: 52, color: KColors.primary),
                ),
              ),
              const SizedBox(height: 22),
              const Text(KStrings.appName, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(KStrings.tagline, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
              const SizedBox(height: 40),
              const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
