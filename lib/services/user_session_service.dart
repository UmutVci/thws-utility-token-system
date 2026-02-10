import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  static const String _knummerKey = 'session_knummer';
  static const String _displayNameKey = 'session_display_name';
  static const String _employeeUsernameKey = 'session_employee_username';

  Future<void> saveKnummer(String knummer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_knummerKey, knummer.trim());
  }

  Future<String?> getKnummer() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_knummerKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> saveDisplayName(String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, displayName.trim());
  }

  Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_displayNameKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> saveEmployeeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeUsernameKey, username.trim());
  }

  Future<String?> getEmployeeUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_employeeUsernameKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_knummerKey);
    await prefs.remove(_displayNameKey);
    await prefs.remove(_employeeUsernameKey);
  }
}
