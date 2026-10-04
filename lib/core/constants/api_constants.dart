import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = AppConfig.supabaseRestBaseUrl;
  static const String anonKey = AppConfig.supabaseAnonKey;

  // Trailing slash required — Dio appends paths without a leading '/'.
  static const String mobileApiBaseUrl = AppConfig.mobileApiBaseUrl;
}
