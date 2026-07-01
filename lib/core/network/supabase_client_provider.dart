import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

// Fallback values used when .env asset is not available in the bundle.
// Replace these with your actual Supabase project credentials.
const _fallbackSupabaseUrl = 'https://mxgdkgunszcfxqhsutqy.supabase.co';
const _fallbackAnonKey =
    'sb_publishable_tkxO7IjjBaujruU3Wjdjzw_pb_7ePG5';

/// Initializes Supabase from environment variables loaded via flutter_dotenv.
/// Call once in [main] before [runApp].
///
/// Hot-restart safe:
/// - [dotenv.isInitialized] guard skips re-loading when already loaded.
/// - [isOptional: true] prevents [FileNotFoundError] if asset bundling fails.
/// - Supabase init is guarded against double-initialization.
Future<void> initSupabase() async {
  if (!dotenv.isInitialized) {
    // isOptional: true — never throws FileNotFoundError.
    // If the .env asset is missing, dotenv will be initialized with an empty map
    // and we fall back to the constants above.
    await dotenv.load(fileName: '.env', isOptional: true);
  }

  final url =
      (dotenv.isInitialized ? dotenv.env['SUPABASE_URL'] : null) ??
      _fallbackSupabaseUrl;

  final anonKey =
      (dotenv.isInitialized ? dotenv.env['SUPABASE_ANON_KEY'] : null) ??
      _fallbackAnonKey;

  // Guard against double-initialization during hot-restart.
  try {
    Supabase.instance.client; // already initialized — skip
  } catch (_) {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
}

/// Exposes the initialized [SupabaseClient] as a Riverpod provider.
/// Inject this wherever direct Supabase access is needed (datasources only).
@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}
