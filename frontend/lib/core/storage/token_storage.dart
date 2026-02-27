import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();

  static const _kToken    = 'auth_token';
  static const _kUsername = 'username';

  static Future<void> save({required String token, required String username}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    await p.setString(_kUsername, username);
  }

  static Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_kToken);

  static Future<String?> readUsername() async =>
      (await SharedPreferences.getInstance()).getString(_kUsername);

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kUsername);
  }
}
