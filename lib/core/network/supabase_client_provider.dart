import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

/// Initializes Supabase from environment variables loaded via flutter_dotenv.
/// Call once in [main] before [runApp].
Future<void> initSupabase() async {
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
}

/// Exposes the initialized [SupabaseClient] as a Riverpod provider.
/// Inject this wherever direct Supabase access is needed (datasources only).
@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}
