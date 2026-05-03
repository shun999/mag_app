import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const _key = 'api_base_url';
  static const defaultUrl = 'http://54.178.174.48:8000';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? defaultUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }
}
