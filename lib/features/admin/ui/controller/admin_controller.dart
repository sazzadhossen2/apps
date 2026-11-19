import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../app/utils.dart';
import '../../../../core/services/api_service/api_services.dart';
import '../../../../core/services/network/network_response.dart';
import '../../../home/models/service_model.dart';
import '../../../my_bookings/models/appointment_model.dart';
import '../../../reviews/models/review_model.dart';
import '../../models/admin_models.dart';

/// Everything the admin panel needs: requests, monthly stats, busy time and service management.
class AdminController extends ChangeNotifier {
  final ApiServices _api = ApiServices.instance;

  // ---------------- requests ----------------
  ViewState requestsState = ViewState.idle;
  String? requestsError;
  List<AppointmentModel> requests = [];
  Map<String, int> counts = {'pending': 0, 'confirmed': 0, 'cancelled': 0, 'completed': 0};
  String? statusFilter = AppointmentStatus.pending; // null = all
  String search = '';
  String? actingId;
  Timer? _debounce;
  int _requestId = 0;

  int get pendingCount => counts['pending'] ?? 0;
  int get allCount => counts.values.fold(0, (a, b) => a + b);

  Future<void> loadRequests({bool silent = false}) async {
    final id = ++_requestId;
    if (!silent || requestsState != ViewState.success) {
      requestsState = ViewState.loading;
      notifyListeners();
    }
    final res = await _api.adminAppointments(status: statusFilter, search: search.isEmpty ? null : search);
    if (id != _requestId) return;

    if (res.isSuccess) {
      requests = res.listOf('items').map(AppointmentModel.fromJson).toList();
      final c = res.dataMap['counts'];
      if (c is Map) counts = {for (final e in c.entries) e.key.toString(): (e.value as num?)?.toInt() ?? 0};
      requestsState = ViewState.success;
      requestsError = null;
    } else {
      requestsError = res.errorMessage;
      requestsState = ViewState.error;
    }
    notifyListeners();
  }

  void setStatusFilter(String? value) {
    statusFilter = value;
    loadRequests();
  }

  void setSearch(String value) {
    search = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), loadRequests);
  }

  /// confirm / cancel (deny) / complete. Returns null on success, otherwise the error message.
  Future<String?> setStatus(String id, String status, {String reason = ''}) async {
    actingId = id;
    notifyListeners();
    final res = await _api.adminSetStatus(id, status, reason: reason);
    actingId = null;
    if (!res.isSuccess) {
      notifyListeners();
      return res.errorMessage;
    }
    await Future.wait([loadRequests(silent: true), loadStats(silent: true)]);
    return null;
  }

  // ---------------- statistics ----------------
  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  ViewState statsState = ViewState.idle;
  String? statsError;
  AdminStats? stats;
  List<ReviewModel> reviews = [];

  bool get isCurrentMonth => month.year == DateTime.now().year && month.month == DateTime.now().month;

  Future<void> loadStats({bool silent = false}) async {
    if (!silent || stats == null) {
      statsState = ViewState.loading;
      notifyListeners();
    }
    final ym = Fmt.ym(month);
    final results = await Future.wait([_api.adminStats(ym), _api.adminReviews(ym)]);
    if (ym != Fmt.ym(month)) return; // user switched month meanwhile

    if (results[0].isSuccess) {
      stats = AdminStats.fromJson(results[0].dataMap);
      reviews = results[1].isSuccess ? results[1].listOf('items').map(ReviewModel.fromJson).toList() : [];
      statsState = ViewState.success;
      statsError = null;
    } else {
      statsError = results[0].errorMessage;
      statsState = ViewState.error;
    }
    notifyListeners();
  }

  void changeMonth(int delta) {
    final next = DateTime(month.year, month.month + delta);
    if (next.isAfter(DateTime(DateTime.now().year, DateTime.now().month))) return; // no future months
    month = next;
    loadStats();
  }

  // ---------------- busy time ----------------
  ViewState busyState = ViewState.idle;
  String? busyError;
  List<BusyBlock> busy = [];

  Future<void> loadBusy({bool silent = false}) async {
    if (!silent || busyState != ViewState.success) {
      busyState = ViewState.loading;
      notifyListeners();
    }
    final res = await _api.adminBusyList();
    if (res.isSuccess) {
      busy = res.listOf('items').map(BusyBlock.fromJson).toList();
      busyState = ViewState.success;
      busyError = null;
    } else {
      busyError = res.errorMessage;
      busyState = ViewState.error;
    }
    notifyListeners();
  }

  /// Returns null on success, otherwise an error message. [info] receives a hint about overlapping bookings.
  Future<String?> addBusy({
    required String date,
    required String from,
    required String to,
    String? serviceId,
    String reason = '',
    void Function(String message)? info,
  }) async {
    final NetworkResponse res = await _api.adminBusyCreate(date: date, from: from, to: to, serviceId: serviceId, reason: reason);
    if (!res.isSuccess) return res.errorMessage;
    final conflicts = (res.dataMap['conflictingBookings'] as num?)?.toInt() ?? 0;
    if (conflicts > 0) info?.call(res.message);
    await loadBusy(silent: true);
    return null;
  }

  Future<String?> removeBusy(String id) async {
    final res = await _api.adminBusyDelete(id);
    if (!res.isSuccess) return res.errorMessage;
    busy = busy.where((b) => b.id != id).toList();
    notifyListeners();
    return null;
  }

  // ---------------- services ----------------
  ViewState servicesState = ViewState.idle;
  String? servicesError;
  List<ServiceModel> services = [];

  Future<void> loadServices({bool silent = false}) async {
    if (!silent || servicesState != ViewState.success) {
      servicesState = ViewState.loading;
      notifyListeners();
    }
    final res = await _api.adminServices();
    if (res.isSuccess) {
      services = res.listOf('items').map(ServiceModel.fromJson).toList();
      servicesState = ViewState.success;
      servicesError = null;
    } else {
      servicesError = res.errorMessage;
      servicesState = ViewState.error;
    }
    notifyListeners();
  }

  /// Create ([id] null) or update. Returns null on success, otherwise the error message.
  Future<String?> saveService(String? id, Map<String, dynamic> body) async {
    final res = id == null ? await _api.adminServiceCreate(body) : await _api.adminServiceUpdate(id, body);
    if (!res.isSuccess) return res.errorMessage;
    await loadServices(silent: true);
    return null;
  }

  /// Called on logout so the next account never sees admin data.
  void reset() {
    _debounce?.cancel();
    requestsState = ViewState.idle;
    requests = [];
    counts = {'pending': 0, 'confirmed': 0, 'cancelled': 0, 'completed': 0};
    statusFilter = AppointmentStatus.pending;
    search = '';
    statsState = ViewState.idle;
    stats = null;
    reviews = [];
    busyState = ViewState.idle;
    busy = [];
    servicesState = ViewState.idle;
    services = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
