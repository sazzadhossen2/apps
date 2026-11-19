import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';
import 'app/urls.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  // Publishable key only (safe in the app). The secret key never leaves the server.
  // The key returned by the server with each payment overrides this one.
  Stripe.publishableKey = Urls.stripePublishableKey;
  runApp(const KicuLagbe());
}
