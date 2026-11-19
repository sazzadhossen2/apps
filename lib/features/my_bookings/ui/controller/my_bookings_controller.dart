import 'package:flutter/foundation.dart';

import '../../../../app/utils.dart';
import '../../../../core/services/api_service/api_services.dart';
import '../../../../core/services/network/network_response.dart';
import '../../../payment/payment_service.dart';
import '../../models/appointment_model.dart';

class MyBookingsController extends ChangeNotifier {
  final ApiServices _api = ApiServices.instance;

  ViewState state = ViewState.idle;
  String? error;
  List<AppointmentModel> upcoming = [];
  List<AppointmentModel> past = [];
  String? cancelError;
  String? cancellingId;
  String? payingId;

  AppointmentModel? byId(String id) {
    for (final a in [...upcoming, ...past]) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// [silent] keeps the current list on screen while refreshing.
  Future<void> load({bool silent = false}) async {
    if (!silent || state == ViewState.idle || state == ViewState.error) {
      state = ViewState.loading;
      notifyListeners();
    }
    final results = await Future.wait([_api.appointments(when: 'upcoming'), _api.appointments(when: 'past')]);

    if (results.every((r) => r.isSuccess)) {
      upcoming = _parse(results[0]);
      past = _parse(results[1]);
      state = ViewState.success;
      error = null;
    } else {
      error = results.firstWhere((r) => !r.isSuccess).errorMessage;
      if (state != ViewState.success) state = ViewState.error;
    }
    notifyListeners();
  }

  List<AppointmentModel> _parse(NetworkResponse res) => res.listOf('items').map(AppointmentModel.fromJson).toList();

  void _replace(AppointmentModel updated) {
    List<AppointmentModel> swap(List<AppointmentModel> l) => [for (final a in l) a.id == updated.id ? updated : a];
    upcoming = swap(upcoming);
    past = swap(past);
  }

  Future<bool> cancel(String id) async {
    cancelError = null;
    cancellingId = id;
    notifyListeners();

    final res = await _api.cancelAppointment(id);
    cancellingId = null;

    if (res.isSuccess) {
      // Use the server's version: a paid booking comes back as "refunded".
      final raw = res.dataMap['appointment'];
      final server = raw is Map ? AppointmentModel.fromJson(Map<String, dynamic>.from(raw)) : null;
      final old = upcoming.where((a) => a.id == id).toList();
      if (old.isNotEmpty) {
        upcoming = upcoming.where((a) => a.id != id).toList();
        past = [server ?? old.first.copyWith(status: AppointmentStatus.cancelled), ...past];
      }
      notifyListeners();
      return true;
    }
    cancelError = res.errorMessage;
    notifyListeners();
    return false;
  }

  /// Opens Stripe's PaymentSheet for this booking. Returns true when paid.
  Future<bool> pay(String id) async {
    if (payingId != null) return false;
    payingId = id;
    notifyListeners();
    final paid = await PaymentFlow.run(id);
    payingId = null;
    if (paid != null) _replace(paid);
    notifyListeners();
    return paid != null;
  }

  /// Marks a booking as reviewed after the review sheet saved it.
  void markReviewed(String id) {
    final a = byId(id);
    if (a != null) _replace(a.copyWith(reviewed: true));
    notifyListeners();
  }

  /// Called on logout so the next user never sees someone else's bookings.
  void reset() {
    state = ViewState.idle;
    upcoming = [];
    past = [];
    error = null;
    notifyListeners();
  }
}
