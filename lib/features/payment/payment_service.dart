import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../app/kstrings.dart';
import '../../app/urls.dart';
import '../../app/utils.dart';
import '../../core/services/api_service/api_services.dart';
import '../../core/services/network/network_response.dart';
import '../my_bookings/models/appointment_model.dart';

class PaymentResult {
  final bool success;
  final bool cancelled;
  final String message;
  final AppointmentModel? appointment;

  const PaymentResult._({required this.success, this.cancelled = false, this.message = '', this.appointment});

  factory PaymentResult.paid(AppointmentModel a) => PaymentResult._(success: true, appointment: a, message: 'Payment successful');
  factory PaymentResult.cancelled() => const PaymentResult._(success: false, cancelled: true, message: 'Payment cancelled');
  factory PaymentResult.failed(String m) => PaymentResult._(success: false, message: m);
}

/// Stripe PaymentSheet flow. The amount is decided by the server, the card data goes straight to Stripe
/// (never through our server), and the server verifies the result with Stripe before marking the booking paid.
class PaymentService {
  PaymentService._();

  static final ApiServices _api = ApiServices.instance;

  static Future<PaymentResult> pay(String appointmentId) async {
    // 1. Server creates the PaymentIntent
    final intent = await _api.createPaymentIntent(appointmentId);
    if (!intent.isSuccess) return PaymentResult.failed(intent.errorMessage);

    final data = intent.dataMap;
    final nestedIntent = data['paymentIntent'];
    final paymentData = nestedIntent is Map
        ? Map<String, dynamic>.from(nestedIntent)
        : data;
    final secret = (paymentData['clientSecret'] ?? paymentData['paymentIntentClientSecret'] ?? paymentData['client_secret'] ?? '').toString();
    if (secret.isEmpty) return PaymentResult.failed('Could not start the payment. Please try again.');

    final serverKey = (paymentData['publishableKey'] ?? paymentData['publishable_key'] ?? data['publishableKey'] ?? data['publishable_key'] ?? '').toString();
    Stripe.publishableKey = serverKey.isNotEmpty ? serverKey : Urls.stripePublishableKey;

    try {
      await Stripe.instance.applySettings();
      // 2. Stripe's secure sheet collects and confirms the card
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: secret,
          merchantDisplayName: KStrings.appName,
          // style: ThemeMode.light,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return PaymentResult.cancelled();
      return PaymentResult.failed(e.error.localizedMessage ?? 'Payment failed. Please try again.');
    } catch (e) {
      if (kDebugMode) debugPrint('Stripe PaymentSheet error: $e');
      return PaymentResult.failed('Payment could not be completed: ${e.toString()}');
    }

    // 3. Server verifies with Stripe and marks the booking paid
    final NetworkResponse confirm = await _api.confirmPayment(appointmentId);
    final confirmData = confirm.dataMap;
    final confirmAppointment = confirmData['appointment'] is Map
        ? confirmData['appointment']
        : (confirmData['appointmentId'] != null ? null : confirmData);
    if (confirm.isSuccess && confirmAppointment is Map) {
      return PaymentResult.paid(AppointmentModel.fromJson(Map<String, dynamic>.from(confirmAppointment)));
    }
    return PaymentResult.failed('Your card was charged but we could not confirm it yet. Pull to refresh in My Bookings.');
  }
}

/// UI helper: runs the flow and reports the outcome with a snackbar. Returns the paid appointment or null.
class PaymentFlow {
  PaymentFlow._();

  static Future<AppointmentModel?> run(String appointmentId) async {
    final result = await PaymentService.pay(appointmentId);
    if (result.success) {
      AppSnack.show('Payment successful. Thank you!');
      return result.appointment;
    }
    if (!result.cancelled) AppSnack.show(result.message, error: true);
    return null;
  }
}
