/// Replace these with your actual Supabase project values before running.
/// Find them in: Supabase Dashboard → Project Settings → API
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  static const String restBaseUrl = '$supabaseUrl/rest/v1';
  static const String rpcBaseUrl = '$supabaseUrl/rest/v1/rpc';
}
