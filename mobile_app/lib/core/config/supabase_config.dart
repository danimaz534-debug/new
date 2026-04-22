import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

class SupabaseConfig {
  const SupabaseConfig._();

  static const String _defaultUrl = "https://hqszihvjqscrwdzrwbyg.supabase.co";
  static const String _defaultAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxc3ppaHZqcXNjcndkenJ3YnlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NzA4NzksImV4cCI6MjA5MTA0Njg3OX0.Oe6Jm4dduicJRhF_cGol7lLjWD3W5nNUiJqSvbhnaII";

  static String get url => kIsWeb 
      ? const String.fromEnvironment("SUPABASE_URL", defaultValue: _defaultUrl)
      : dotenv.env["SUPABASE_URL"] ?? _defaultUrl;

  static String get anonKey => kIsWeb
      ? const String.fromEnvironment("SUPABASE_ANON_KEY", defaultValue: _defaultAnonKey)
      : dotenv.env["SUPABASE_ANON_KEY"] ?? _defaultAnonKey;

  static bool get debugMode => kIsWeb
      ? const String.fromEnvironment("DEBUG_MODE", defaultValue: "true") == "true"
      : dotenv.env["DEBUG_MODE"]?.toLowerCase() == "true";
}
