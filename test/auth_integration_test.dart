// ignore_for_file: avoid_print
//
// Standalone auth integration test — run directly with Dart, NOT with
// `flutter test` (it uses Supabase which requires real network access and
// platform channels not available in the test VM).
//
// Usage:
//   dart test/auth_integration_test.dart

import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://mxgdkgunszcfxqhsutqy.supabase.co';
const String supabaseKey = 'sb_publishable_tkxO7IjjBaujruU3Wjdjzw_pb_7ePG5';

final accounts = [
  {'email': 'sohasara853@gmail.com', 'password': 'nadia12345'},
  {'email': 'nadiaislamrupa853@gmail.com', 'password': 'rupa@123'},
];

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
  final client = Supabase.instance.client;

  print('=' * 60);
  print('Chatify Auth Integration Test');
  print('=' * 60);

  for (final account in accounts) {
    final email = account['email']!;
    final password = account['password']!;
    print('\n--- Testing: $email ---');

    try {
      final res = await client.auth
          .signInWithPassword(email: email, password: password);
      final user = res.user;
      if (user == null) {
        print('  [FAIL] Sign in returned null user');
        continue;
      }
      print('  [PASS] Sign in succeeded  uid=${user.id}');

      final profileRes = await client
          .from('profile')
          .select('id, name')
          .eq('id', user.id)
          .maybeSingle();

      if (profileRes == null) {
        print('  [INFO] No profile row → /create-profile');
      } else {
        print('  [INFO] Profile exists → /home/chats');
        print('         name: ${profileRes['name'] ?? '(not set)'}');
      }

      await client.auth.signOut();
      print('  [PASS] Sign out succeeded');
    } on AuthException catch (e) {
      print('  [FAIL] AuthException: ${e.message}');
    } catch (e) {
      print('  [FAIL] Error: $e');
    }
  }

  print('\n${'=' * 60}\nDone.\n${'=' * 60}');
}
