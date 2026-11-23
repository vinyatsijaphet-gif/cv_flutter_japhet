import 'package:shared_preferences/shared_preferences.dart';

/// Garde l'utilisateur connecté entre deux lancements de l'application.
class Session {
  static const _kId = 'account_id';
  static const _kEmail = 'account_email';

  static Future<void> save(int id, String email) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kId, id);
    await p.setString(_kEmail, email);
  }

  static Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.containsKey(_kId);
  }

  static Future<String?> email() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kEmail);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kId);
    await p.remove(_kEmail);
  }
}
