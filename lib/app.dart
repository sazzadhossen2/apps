import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_router.dart';
import 'app/app_theme.dart';
import 'app/kstrings.dart';
import 'app/utils.dart';
import 'controller_binder.dart';
import 'features/auth/ui/screens/splash_screen.dart';


class KicuLagbe extends StatelessWidget {
  const KicuLagbe({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ControllerBinding.providers,
      child: MaterialApp(
        title: KStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: AppSnack.key,
        home: const SplashScreen(),
      ),
    );
  }
}
