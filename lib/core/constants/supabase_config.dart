import 'package:shared_preferences/shared_preferences.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Default credentials (can be overridden via Admin Settings screen)
  static String supabaseUrl = 'https://your-project.supabase.co';
  static String supabaseAnonKey = 'your-anon-key-here';

  static const String keyUrl = 'cafeku_supabase_url';
  static const String keyAnonKey = 'cafeku_supabase_anon_key';
  static const String keyUseMock = 'cafeku_use_mock_data';

  static bool isConfigured() {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        !supabaseUrl.contains('your-project') &&
        !supabaseAnonKey.contains('your-anon-key');
  }

  static Future<void> loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(keyUrl);
    final savedKey = prefs.getString(keyAnonKey);
    if (savedUrl != null && savedUrl.isNotEmpty) {
      supabaseUrl = savedUrl;
    }
    if (savedKey != null && savedKey.isNotEmpty) {
      supabaseAnonKey = savedKey;
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
