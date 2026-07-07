class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static void validate() {
    if (url.isNotEmpty && publishableKey.isNotEmpty) return;

    throw StateError(
      'Missing Supabase configuration. '
      'Run with --dart-define-from-file=.env',
    );
  }
}
