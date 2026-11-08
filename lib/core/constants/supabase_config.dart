import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Loaded dynamically at runtime from .env (no hardcoded sensitive credentials)
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';

  static const String keyUrl = 'cafeku_supabase_url';
  static const String keyAnonKey = 'cafeku_supabase_anon_key';
  static const String keyUseMock = 'cafeku_use_mock_data';

  static bool isConfigured() {
    return supabaseUrl.trim().isNotEmpty &&
        supabaseAnonKey.trim().isNotEmpty &&
        !supabaseUrl.contains('your-project') &&
        !supabaseAnonKey.contains('your-anon-key');
  }

  static Future<void> loadSavedConfig() async {
    // 1. Try to load credentials from .env file
    try {
      await dotenv.load(fileName: ".env");
      final envUrl = dotenv.env['SUPABASE_URL'];
      final envKey = dotenv.env['SUPABASE_ANON_KEY'];
      if (envUrl != null && envUrl.trim().isNotEmpty) {
        supabaseUrl = envUrl.trim();
      }
      if (envKey != null && envKey.trim().isNotEmpty) {
        supabaseAnonKey = envKey.trim();
      }
      if (isConfigured()) {
        debugPrint('Loaded Supabase config from .env successfully.');
      } else {
        debugPrint('Notice: Supabase credentials empty in .env. Running in Demo mode.');
      }
    } catch (e) {
      debugPrint('Notice: .env file not loaded ($e). Running in Demo mode.');
    }

    // 2. Load any user override saved in SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(keyUrl);
      final savedKey = prefs.getString(keyAnonKey);
      if (savedUrl != null && savedUrl.isNotEmpty) {
        supabaseUrl = savedUrl;
      }
      if (savedKey != null && savedKey.isNotEmpty) {
        supabaseAnonKey = savedKey;
      }
    } catch (e) {
      debugPrint('Notice: SharedPreferences error: $e');
    }
  }

  static Future<void> saveConfig(String url, String key) async {
    supabaseUrl = url;
    supabaseAnonKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUrl, url);
    await prefs.setString(keyAnonKey, key);
  }
}
