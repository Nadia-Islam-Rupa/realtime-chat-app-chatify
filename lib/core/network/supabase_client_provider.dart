import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

/// Initializes Supabase from environment variables loaded via flutter_dotenv.
/// Call once in [main] before [runApp].
Future<void> initSupabase() async {
  // Load .env; mergeWith keeps any previously-loaded values so repeated
  // calls (e.g. during hot-restart in debug mode) don't throw.
  await dotenv.load(fileName: '.env', mergeWith: {});

  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

  assert(url != null && url.isNotEmpty, 'SUPABASE_URL is missing from .env');
  assert(
    anonKey != null && anonKey.isNotEmpty,
    'SUPABASE_ANON_KEY is missing from .env',
  );

  await Supabase.initialize(
    url: url!,
    anonKey: anonKey!,
  );
}

/// Exposes the initialized [SupabaseClient] as a Riverpod provider.
/// Inject this wherever direct Supabase access is needed (datasources only).
@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}
