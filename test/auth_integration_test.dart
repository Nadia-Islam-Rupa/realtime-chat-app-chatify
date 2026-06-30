// ignore_for_file: avoid_print
// A standalone integration test for the Supabase auth module.
// Run with: dart test/auth_integration_test.dart

import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://mxgdkgunszcfxqhsutqy.supabase.co';
const String supabaseKey = 'sb_publishable_tkxO7IjjBaujruU3Wjdjzw_pb_7ePG5';

// Test accounts
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

    // ---- Sign in ----
    try {
      final res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) {
        print('  [FAIL] Sign in returned null user');
        continue;
      }

      print('  [PASS] Sign in succeeded');
      print('         user.id    : ${user.id}');
      print('         user.email : ${user.email}');
      print('         created_at : ${user.createdAt}');
      print('         session    : ${res.session != null ? "present (expires ${res.session!.expiresAt})" : "none"}');

      // ---- Profile check ----
      final profileRes = await client
          .from('profile')
          .select('id, display_name')
          .eq('id', user.id)
          .maybeSingle();

      if (profileRes == null) {
        print('  [INFO] No profile row found → would redirect to /create-profile');
      } else {
        print('  [INFO] Profile exists → would redirect to /home');
        print('         display_name: ${profileRes['display_name'] ?? '(not set)'}');
      }

      // ---- Login history insert ----
      try {
        await client.from('login_history').insert({
          'user_id': user.id,
          'email': user.email,
          'login_at': DateTime.now().toIso8601String(),
          'device': 'Dart test runner',
          'ip_address': null,
        });
        print('  [PASS] login_history insert succeeded');
      } catch (e) {
        print('  [WARN] login_history insert failed: $e');
        print('         (Table may not exist yet in Supabase — create it to enable this feature)');
      }

      // ---- Sign out ----
      await client.auth.signOut();
      print('  [PASS] Sign out succeeded');
    } on AuthException catch (e) {
      print('  [FAIL] AuthException: ${e.message}');
    } catch (e) {
      print('  [FAIL] Unexpected error: $e');
    }
  }

  print('\n${'=' * 60}');
  print('Test complete.');
  print('=' * 60);
}
