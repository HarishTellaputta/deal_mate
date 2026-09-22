import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  static const String _tokenKey = 'business_admin_token';
  static const String _userIdKey = 'business_admin_user_id';
  static const String _businessIdKey = 'business_admin_business_id';
  static const String _roleKey = 'business_admin_role';

  Future<void> saveLogin({
    required String token,
    required int userId,
    int? businessId,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_roleKey, role);

    if (businessId != null) {
      await prefs.setInt(_businessIdKey, businessId);
    } else {
      await prefs.remove(_businessIdKey);
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<int?> getBusinessId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_businessIdKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_businessIdKey);
    await prefs.remove(_roleKey);
  }
}