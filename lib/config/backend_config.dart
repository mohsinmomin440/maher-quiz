// Supabase connection, supplied at build time so no keys live in source:
//
//   flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
//               --dart-define=SUPABASE_ANON_KEY=eyJ...
//
// The anon key is the *public* client key (safe to ship in the app; access is
// enforced by row-level security). Never put the service_role key here.
// When either value is missing the app runs fully offline/local, as before.
// See SUPABASE_SETUP.md.
class BackendConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isEnabled =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
