import 'package:flutter/foundation.dart';


import '../shared_preference/shared_preference.dart';

/// In-memory auth state backed by secure storage (persistent login).
class Session {
  Session._();
  static final Session instance = Session._();

  String? _token;
  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Called when the API rejects the stored token (expired / revoked).
  VoidCallback? onExpired;

  Future<void> restore() async => _token = await LocalStore.instance.readToken();

  Future<void> start(String token) async {
    _token = token;
    await LocalStore.instance.writeToken(token);
  }

  Future<void> end() async {
    _token = null;
    await LocalStore.instance.clear();
  }

  Future<void> expire() async {
    await end();
    onExpired?.call();
  }
}
