/* imports */
import 'package:shared_preferences/shared_preferences.dart';

/* classes */
class SessionManager {
  static const String _keyToken = "user_token";

  static Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }
}
