import 'package:flutter/foundation.dart';

import '../../../../app/app_router.dart';
import '../../../../app/utils.dart';
import '../../../../core/services/api_service/api_services.dart';
import '../../../../core/services/network/network_response.dart';
import '../../../../core/services/session/session.dart';
import '../../models/user_model.dart';

/// Result of login/register: what the UI should do next.
enum AuthNext { home, verifyEmail, failed }

class AuthController extends ChangeNotifier {
  final ApiServices _api = ApiServices.instance;

  UserModel? _user;
  bool _busy = false;
  String? _error;

  UserModel? get user => _user;
  bool get isBusy => _busy;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  /// Splash: restores a saved session. Returns true when the user is still logged in.
  Future<bool> bootstrap() async {
    await Session.instance.restore();
    if (!Session.instance.hasToken) return false;

    final res = await _api.me();
    // Handle expired sessions from now on (after the first check).
    Session.instance.onExpired = _handleExpired;

    if (res.isSuccess) {
      _user = UserModel.fromJson(Map<String, dynamic>.from(res.dataMap['user'] as Map));
      notifyListeners();
      return true;
    }
    return false;
  }

  void _handleExpired() {
    _user = null;
    notifyListeners();
    AppRouter.resetToLogin();
    AppSnack.show('Your session has expired. Please log in again.', error: true);
  }

  Future<AuthNext> login(String email, String password) async {
    _error = null;
    _setBusy(true);
    final res = await _api.login(email.trim(), password);
    if (!res.isSuccess && res.code == 'EMAIL_NOT_VERIFIED') {
      _busy = false;
      notifyListeners();
      return AuthNext.verifyEmail; // the server already emailed a fresh code
    }
    return await _finishAuth(res) ? AuthNext.home : AuthNext.failed;
  }

  /// Creates the account. The server emails a code; there is no session until it is verified.
  Future<bool> register(String name, String email, String password) async {
    _error = null;
    _setBusy(true);
    final res = await _api.register(name.trim(), email.trim(), password);
    _busy = false;
    if (!res.isSuccess) _error = res.errorMessage;
    notifyListeners();
    return res.isSuccess;
  }

  /// Confirms the emailed code and starts the session.
  Future<bool> verifyEmail(String email, String otp) async {
    _error = null;
    _setBusy(true);
    final res = await _api.verifyOtp(email.trim(), otp.trim());
    return _finishAuth(res);
  }

  Future<bool> resendCode(String email) async {
    _error = null;
    final res = await _api.resendOtp(email.trim());
    if (!res.isSuccess) {
      _error = res.errorMessage;
      notifyListeners();
    }
    return res.isSuccess;
  }

  Future<bool> forgotPassword(String email) async {
    _error = null;
    _setBusy(true);
    final res = await _api.forgotPassword(email.trim());
    _busy = false;
    if (!res.isSuccess) _error = res.errorMessage;
    notifyListeners();
    return res.isSuccess;
  }

  Future<bool> resetPassword(String email, String otp, String newPassword) async {
    _error = null;
    _setBusy(true);
    final res = await _api.resetPassword(email.trim(), otp.trim(), newPassword);
    _busy = false;
    if (!res.isSuccess) _error = res.errorMessage;
    notifyListeners();
    return res.isSuccess;
  }

  Future<bool> _finishAuth(NetworkResponse res) async {
    if (res.isSuccess) {
      final data = res.dataMap;
      await Session.instance.start(data['token'].toString());
      _user = UserModel.fromJson(Map<String, dynamic>.from(data['user'] as Map));
      Session.instance.onExpired = _handleExpired;
      _busy = false;
      notifyListeners();
      return true;
    }
    _error = res.errorMessage;
    _setBusy(false);
    return false;
  }

  Future<bool> updateProfile({required String name, required String phone}) async {
    _error = null;
    _setBusy(true);
    final res = await _api.updateProfile(name: name.trim(), phone: phone.trim());
    if (res.isSuccess) {
      _user = UserModel.fromJson(Map<String, dynamic>.from(res.dataMap['user'] as Map));
      _busy = false;
      notifyListeners();
      return true;
    }
    _error = res.errorMessage;
    _setBusy(false);
    return false;
  }

  Future<bool> changePassword(String current, String next) async {
    _error = null;
    _setBusy(true);
    final res = await _api.changePassword(current, next);
    if (!res.isSuccess) _error = res.errorMessage;
    _setBusy(false);
    return res.isSuccess;
  }

  Future<void> logout() async {
    Session.instance.onExpired = null;
    _api.logout(); // fire and forget; the token is discarded locally anyway
    await Session.instance.end();
    _user = null;
    notifyListeners();
  }
}
