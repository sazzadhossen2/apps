class Urls {
  Urls._();

  /// Backend address. Override at build time:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.0.104:5001/api/v1
  ///   flutter build apk --dart-define=API_BASE_URL=https://your-api.example.com/api/v1
  /// Default is the computer LAN IP for the connected physical Android phone.
  /// Android emulator use http://10.0.2.2:5001/api/v1.
  static const String baseUrl = String.fromEnvironment(
    'https://backend-9cbi.onrender.com/api/v1',
    defaultValue: 'https://backend-9cbi.onrender.com/api/v1',
  );

  /// Stripe PUBLISHABLE key (safe to ship in the app; the secret key stays on the server).
  /// The server also returns it with every payment, so this is only a fallback.
  /// Prefer a test key (pk_test_...) while developing: a live key charges real cards.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51UcoftFb3VNXxx0tkJMRkBetna5bNFh4h78RHajFXYbZj3uLduYePonwrYgxtbIb30qLgylZy4v1vslVj2Vc5RHW00FsV44bYL',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // User
  static const String me = '/users/me';
  static const String changePassword = '/users/me/password';

  // Services
  static const String services = '/services';
  static const String categories = '/services/categories';
  static String service(String id) => '/services/$id';
  static String availability(String id) => '/services/$id/availability';
  static String serviceReviews(String id) => '/services/$id/reviews';

  // Appointments
  static const String appointments = '/appointments';
  static String appointment(String id) => '/appointments/$id';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';

  // Reviews & payments
  static const String reviews = '/reviews';
  static const String paymentIntent = '/payments/intent';
  static const String paymentConfirm = '/payments/confirm';

  // AI
  static const String aiChat = '/ai/chat';

  // Admin
  static const String adminAppointments = '/admin/appointments';
  static String adminAppointmentStatus(String id) => '/admin/appointments/$id/status';
  static const String adminStats = '/admin/stats';
  static const String adminReviews = '/admin/reviews';
  static const String adminBusy = '/admin/busy';
  static String adminBusyItem(String id) => '/admin/busy/$id';
  static const String adminServices = '/admin/services';
  static String adminService(String id) => '/admin/services/$id';
}
