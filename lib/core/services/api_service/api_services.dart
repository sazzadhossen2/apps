
import '../../../app/urls.dart';
import '../network/network_client.dart';
import '../network/network_response.dart';

/// Every REST endpoint used by the app, in one place.
class ApiServices {
  ApiServices._();
  static final ApiServices instance = ApiServices._();

  final NetworkClient _c = NetworkClient();

  // ---- Auth ----
  Future<NetworkResponse> login(String email, String password) =>
      _c.request('POST', Urls.login, body: {'email': email, 'password': password}, auth: false);

  Future<NetworkResponse> register(String name, String email, String password) => _c.request(
        'POST',
        Urls.register,
        body: {'name': name, 'email': email, 'password': password},
        auth: false,
      );

  Future<NetworkResponse> verifyOtp(String email, String otp) =>
      _c.request('POST', Urls.verifyOtp, body: {'email': email, 'otp': otp}, auth: false);

  Future<NetworkResponse> resendOtp(String email) =>
      _c.request('POST', Urls.resendOtp, body: {'email': email}, auth: false);

  Future<NetworkResponse> forgotPassword(String email) =>
      _c.request('POST', Urls.forgotPassword, body: {'email': email}, auth: false);

  Future<NetworkResponse> resetPassword(String email, String otp, String newPassword) => _c.request(
        'POST',
        Urls.resetPassword,
        body: {'email': email, 'otp': otp, 'newPassword': newPassword},
        auth: false,
      );

  Future<NetworkResponse> logout() => _c.request('POST', Urls.logout);

  // ---- User ----
  Future<NetworkResponse> me() => _c.request('GET', Urls.me);

  Future<NetworkResponse> updateProfile({required String name, required String phone}) =>
      _c.request('PUT', Urls.me, body: {'name': name, 'phone': phone});

  Future<NetworkResponse> changePassword(String current, String next) => _c.request(
        'PUT',
        Urls.changePassword,
        body: {'currentPassword': current, 'newPassword': next},
      );

  // ---- Services ----
  Future<NetworkResponse> services({
    String? search,
    String? category,
    String? sort,
    double? minPrice,
    double? maxPrice,
    bool featuredOnly = false,
    int limit = 50,
  }) =>
      _c.request('GET', Urls.services, query: {
        'search': search,
        'category': category,
        'sort': sort,
        'minPrice': minPrice?.round(),
        'maxPrice': maxPrice?.round(),
        'featured': featuredOnly ? 'true' : null,
        'limit': limit,
      });

  Future<NetworkResponse> categories() => _c.request('GET', Urls.categories);

  Future<NetworkResponse> serviceById(String id) => _c.request('GET', Urls.service(id));

  Future<NetworkResponse> availability(String serviceId, String date) =>
      _c.request('GET', Urls.availability(serviceId), query: {'date': date});

  // ---- Appointments ----
  Future<NetworkResponse> createAppointment({
    required String serviceId,
    required String startAtIso,
    String notes = '',
  }) =>
      _c.request('POST', Urls.appointments, body: {
        'serviceId': serviceId,
        'startAt': startAtIso,
        if (notes.trim().isNotEmpty) 'notes': notes.trim(),
      });

  Future<NetworkResponse> appointments({required String when}) =>
      _c.request('GET', Urls.appointments, query: {'when': when});

  Future<NetworkResponse> appointmentById(String id) => _c.request('GET', Urls.appointment(id));

  Future<NetworkResponse> cancelAppointment(String id) => _c.request('PATCH', Urls.cancelAppointment(id));

  // ---- AI ----
  Future<NetworkResponse> aiChat(String message, List<Map<String, String>> history) =>
      _c.request('POST', Urls.aiChat, body: {'message': message, 'history': history});

  // ---- Reviews ----
  Future<NetworkResponse> createReview({required String appointmentId, required int rating, String comment = ''}) =>
      _c.request('POST', Urls.reviews, body: {'appointmentId': appointmentId, 'rating': rating, 'comment': comment.trim()});

  Future<NetworkResponse> serviceReviews(String serviceId, {int limit = 20}) =>
      _c.request('GET', Urls.serviceReviews(serviceId), query: {'limit': limit});

  // ---- Payments ----
  Future<NetworkResponse> createPaymentIntent(String appointmentId) =>
      _c.request('POST', Urls.paymentIntent, body: {'appointmentId': appointmentId});

  Future<NetworkResponse> confirmPayment(String appointmentId) =>
      _c.request('POST', Urls.paymentConfirm, body: {'appointmentId': appointmentId});

  // ---- Admin ----
  Future<NetworkResponse> adminAppointments({String? status, String? search, String? date, int limit = 100}) =>
      _c.request('GET', Urls.adminAppointments, query: {'status': status, 'search': search, 'date': date, 'limit': limit});

  Future<NetworkResponse> adminSetStatus(String id, String status, {String reason = ''}) => _c.request(
        'PATCH',
        Urls.adminAppointmentStatus(id),
        body: {'status': status, if (reason.trim().isNotEmpty) 'reason': reason.trim()},
      );

  Future<NetworkResponse> adminStats(String month) => _c.request('GET', Urls.adminStats, query: {'month': month});

  Future<NetworkResponse> adminReviews(String month) => _c.request('GET', Urls.adminReviews, query: {'month': month, 'limit': 50});

  Future<NetworkResponse> adminBusyList() => _c.request('GET', Urls.adminBusy);

  Future<NetworkResponse> adminBusyCreate({
    required String date,
    required String from,
    required String to,
    String? serviceId,
    String reason = '',
  }) =>
      _c.request('POST', Urls.adminBusy, body: {
        'date': date,
        'from': from,
        'to': to,
        'serviceId': serviceId,
        if (reason.trim().isNotEmpty) 'reason': reason.trim(),
      });

  Future<NetworkResponse> adminBusyDelete(String id) => _c.request('DELETE', Urls.adminBusyItem(id));

  Future<NetworkResponse> adminServices() => _c.request('GET', Urls.adminServices);

  Future<NetworkResponse> adminServiceCreate(Map<String, dynamic> body) => _c.request('POST', Urls.adminServices, body: body);

  Future<NetworkResponse> adminServiceUpdate(String id, Map<String, dynamic> body) =>
      _c.request('PUT', Urls.adminService(id), body: body);
}
