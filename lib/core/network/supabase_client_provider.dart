import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

/// Initializes Supabase from environment variables loaded via flutter_dotenv.
/// Call once in [main] before [runApp].
///
/// Safe to call multiple times (e.g. hot-restart in debug mode):
/// - dotenv uses [mergeWith] so it won't throw FileNotFoundError on re-load.
/// - Supabase.initialize is skipped if already initialized.
Future<void> initSupabase() async {
  // mergeWith: {} prevents FileNotFoundError on hot-restart when dotenv
  // is already populated from a previous load.
  await dotenv.load(fileName: '.env', mergeWith: {});

  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

  assert(
    url != null && url.isNotEmpty,
    'SUPABASE_URL is missing or empty in .env',
  );
  assert(
    anonKey != null && anonKey.isNotEmpty,
    'SUPABASE_ANON_KEY is missing or empty in .env',
  );

  // Guard against double-initialization during hot-restart.
  // Supabase.instance throws if not yet initialized, so we check via try/catch.
  try {
    Supabase.instance.client; // already initialized, nothing to do
  } catch (_) {
    await Supabase.initialize(
      url: url!,
      anonKey: anonKey!,
    );
  }
}

/// Exposes the initialized [SupabaseClient] as a Riverpod provider.
/// Inject this wherever direct Supabase access is needed (datasources only).
@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}
