import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../models/user_model.dart';

part 'auth_remote_data_source.g.dart';

/// Contract for all remote auth operations.
abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  UserModel? get currentUser;

  Stream<UserModel?> get onAuthStateChange;
}

/// Supabase-backed implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final sb.SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          'Sign-up succeeded but no user was returned. '
          'Check if email confirmation is required.',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Sign-in failed: no user returned.');
      }

      final model = UserModel.fromSupabaseUser(user);

      // Fire-and-forget login history insert — never block the auth flow.
      _insertLoginHistory(model).ignore();

      return model;
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  UserModel? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : UserModel.fromSupabaseUser(user);
  }

  @override
  Stream<UserModel?> get onAuthStateChange {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user == null ? null : UserModel.fromSupabaseUser(user);
    });
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _insertLoginHistory(UserModel user) async {
    try {
      final device = await _getDeviceDescription();

      await _client.from(AppConstants.loginHistoryTable).insert({
        'user_id': user.id,
        'email': user.email,
        'login_at': DateTime.now().toIso8601String(),
        'device': device,
        'ip_address': null,
      });
    } catch (_) {
      // Login history is best-effort; silently swallow any errors.
    }
  }

  Future<String> _getDeviceDescription() async {
    try {
      final info = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await info.webBrowserInfo;
        return '${web.browserName.name} on ${web.platform ?? 'Web'}';
      }
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        return '${android.manufacturer} ${android.model} (Android ${android.version.release})';
      }
      if (Platform.isIOS) {
        final ios = await info.iosInfo;
        return '${ios.name} ${ios.systemVersion}';
      }
      if (Platform.isLinux) {
        final linux = await info.linuxInfo;
        return 'Linux — ${linux.prettyName}';
      }
      if (Platform.isMacOS) {
        final mac = await info.macOsInfo;
        return 'macOS ${mac.osRelease}';
      }
      if (Platform.isWindows) {
        final win = await info.windowsInfo;
        return 'Windows — ${win.productName}';
      }
      return 'Unknown device';
    } catch (_) {
      return 'Unknown device';
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}
