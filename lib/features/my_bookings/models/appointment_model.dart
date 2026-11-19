import '../../../app/utils.dart';
import '../../home/models/service_model.dart';

/// Customer info the admin sees on a request (null in the customer app).
class CustomerInfo {
  final String id;
  final String name;
  final String email;
  final String phone;

  const CustomerInfo({required this.id, required this.name, required this.email, this.phone = ''});

  factory CustomerInfo.fromJson(Map<String, dynamic> j) => CustomerInfo(
        id: (j['id'] ?? j['_id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
      );
}

class AppointmentModel {
  final String id;
  final ServiceModel? service;
  final String serviceId;
  final CustomerInfo? customer;
  final DateTime startAt; // local time
  final DateTime endAt; // local time
  final String status;
  final String notes;
  final String adminNote;
  final double price;
  final String paymentStatus;
  final bool reviewed;
  final DateTime createdAt;

  const AppointmentModel({
    required this.id,
    required this.service,
    required this.serviceId,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.notes,
    required this.price,
    required this.createdAt,
    this.customer,
    this.adminNote = '',
    this.paymentStatus = PaymentStatus.unpaid,
    this.reviewed = false,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> j) {
    final svc = j['service'];
    final hasService = svc is Map;
    final usr = j['user'];
    return AppointmentModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      service: hasService ? ServiceModel.fromJson(Map<String, dynamic>.from(svc)) : null,
      serviceId: hasService ? (svc['id'] ?? svc['_id'] ?? '').toString() : (svc ?? '').toString(),
      // The API populates `user` only for admins.
      customer: usr is Map ? CustomerInfo.fromJson(Map<String, dynamic>.from(usr)) : null,
      startAt: DateTime.parse(j['startAt'].toString()).toLocal(),
      endAt: DateTime.parse(j['endAt'].toString()).toLocal(),
      status: (j['status'] ?? AppointmentStatus.pending).toString(),
      notes: (j['notes'] ?? '').toString(),
      adminNote: (j['adminNote'] ?? '').toString(),
      price: (j['price'] as num?)?.toDouble() ?? 0,
      paymentStatus: (j['paymentStatus'] ?? PaymentStatus.unpaid).toString(),
      reviewed: j['reviewed'] == true,
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString())?.toLocal() ?? DateTime.now(),
    );
  }

  AppointmentModel copyWith({String? status, String? paymentStatus, bool? reviewed, String? adminNote}) => AppointmentModel(
        id: id,
        service: service,
        serviceId: serviceId,
        customer: customer,
        startAt: startAt,
        endAt: endAt,
        status: status ?? this.status,
        notes: notes,
        adminNote: adminNote ?? this.adminNote,
        price: price,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        reviewed: reviewed ?? this.reviewed,
        createdAt: createdAt,
      );

  bool get isPending => status == AppointmentStatus.pending;
  bool get isConfirmed => status == AppointmentStatus.confirmed;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isPaid => paymentStatus == PaymentStatus.paid;

  /// Pending / confirmed bookings that have not been paid yet can be paid online.
  bool get canPay => (isPending || isConfirmed) && paymentStatus == PaymentStatus.unpaid;
  bool get canReview => isCompleted && !reviewed;

  String get serviceName => service?.name ?? 'Service';
  int get durationMinutes => endAt.difference(startAt).inMinutes;
  String get shortId => id.length > 8 ? id.substring(id.length - 8).toUpperCase() : id.toUpperCase();
}
