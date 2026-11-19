import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT in the platform keystore (Android Keystore / iOS Keychain).
class LocalStore {
  LocalStore._();
  static final LocalStore instance = LocalStore._();

  static const String _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeToken(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clear() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
  }
}
