import 'package:flutter/material.dart';

import '../../../../app/utils.dart';
import '../../../../core/services/api_service/api_services.dart';
import '../../../../core/services/network/network_response.dart';
import '../../../home/models/service_model.dart';
import '../../../my_bookings/models/appointment_model.dart';
import '../../models/slot_model.dart';

/// Screen-scoped controller for the booking flow of one service.
class BookingController extends ChangeNotifier {
  BookingController(this.service) {
    selectedDate = DateUtils.dateOnly(DateTime.now());
    loadSlots();
  }

  final ServiceModel service;
  final ApiServices _api = ApiServices.instance;

  late DateTime selectedDate;
  List<SlotModel> slots = [];
  SlotModel? selectedSlot;
  ViewState slotsState = ViewState.idle;
  String? slotsError;
  bool submitting = false;
  String notes = '';
  String? submitError;
  int _requestId = 0;
  bool _disposed = false;

  bool get allBooked => slots.isNotEmpty && slots.every((s) => !s.available);

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> selectDate(DateTime date) async {
    final d = DateUtils.dateOnly(date);
    if (d == selectedDate && slotsState != ViewState.error) return;
    selectedDate = d;
    selectedSlot = null;
    await loadSlots();
  }

  void selectSlot(SlotModel slot) {
    if (!slot.available) return;
    selectedSlot = slot;
    notifyListeners();
  }

  Future<void> loadSlots() async {
    final id = ++_requestId;
    slotsState = ViewState.loading;
    slotsError = null;
    notifyListeners();

    final res = await _api.availability(service.id, Fmt.ymd(selectedDate));
    if (id != _requestId) return;

    if (res.isSuccess) {
      slots = res.listOf('slots').map(SlotModel.fromJson).toList();
      // Keep the chosen slot only if it is still free.
      if (selectedSlot != null) {
        final still = slots.where((s) => s.startAtUtc == selectedSlot!.startAtUtc && s.available);
        selectedSlot = still.isEmpty ? null : still.first;
      }
      slotsState = ViewState.success;
    } else {
      slots = [];
      slotsError = res.errorMessage;
      slotsState = ViewState.error;
    }
    notifyListeners();
  }

  /// Returns the created appointment, or null (see [submitError]).
  Future<AppointmentModel?> submit() async {
    final slot = selectedSlot;
    if (slot == null || submitting) return null;

    submitting = true;
    submitError = null;
    notifyListeners();

    final res = await _api.createAppointment(
      serviceId: service.id,
      startAtIso: slot.startAtUtc.toIso8601String(),
      notes: notes,
    );

    submitting = false;
    if (res.isSuccess && res.dataMap['appointment'] is Map) {
      notifyListeners();
      return AppointmentModel.fromJson(Map<String, dynamic>.from(res.dataMap['appointment'] as Map));
    }

    submitError = res.errorMessage;
    if (res.statusCode == 409 || res.statusCode == 400) {
      // The slot was taken meanwhile: refresh so the user sees the real availability.
      selectedSlot = null;
      await loadSlots();
    } else {
      notifyListeners();
    }
    return null;
  }
}
