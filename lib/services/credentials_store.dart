import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialsStore {
  static final FlutterSecureStorage _secure = FlutterSecureStorage();
  static const _lastEmailKey = 'last_email';

  static Future<void> saveLastEmail(String email) async {
    await _secure.write(key: _lastEmailKey, value: email);
  }

  static Future<String?> readLastEmail() async {
    return await _secure.read(key: _lastEmailKey);
  }
}
