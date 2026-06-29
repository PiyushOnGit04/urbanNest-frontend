import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String tokenKey = "jwt_token";
  static const String userIdKey = "user_id";

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userIdKey, userId);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
  }
}
