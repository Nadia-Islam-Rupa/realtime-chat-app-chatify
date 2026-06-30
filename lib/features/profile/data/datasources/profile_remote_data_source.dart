import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;
import 'package:supabase_flutter/supabase_flutter.dart' as sb
    show StorageException;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../models/profile_model.dart';

part 'profile_remote_data_source.g.dart';

// ---------------------------------------------------------------------------
// Contract
// ---------------------------------------------------------------------------

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> createProfile(ProfileModel model);
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> updateProfile(ProfileModel model);
  Future<String> uploadProfileImage(File image, String userId);
  Future<void> setOnlineStatus({required String userId, required bool isOnline});
  Stream<ProfileModel> getProfileStream(String userId);
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  static const String _bucket = 'profile-images';

  @override
  Future<ProfileModel> createProfile(ProfileModel model) async {
    try {
      final data = await _client
          .from(AppConstants.profilesTable)
          .insert(model.toMap())
          .select()
          .single();
      return ProfileModel.fromMap(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final data = await _client
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();
      return ProfileModel.fromMap(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') throw NotFoundException('Profile not found.');
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel model) async {
    try {
      final data = await _client
          .from(AppConstants.profilesTable)
          .update(model.toMap())
          .eq('id', model.id)
          .select()
          .single();
      return ProfileModel.fromMap(data);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      final ext = image.path.split('.').last.toLowerCase();
      final path = '$userId/avatar.$ext';

      await _client.storage.from(_bucket).upload(
            path,
            image,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage.from(_bucket).getPublicUrl(path);
      // Cache-bust so the new image is always fetched.
      return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } on sb.StorageException catch (e) {
      throw StorageException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> setOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    try {
      final update = <String, dynamic>{'is_online': isOnline};
      if (!isOnline) {
        update['last_seen'] = DateTime.now().toIso8601String();
      }
      await _client
          .from(AppConstants.profilesTable)
          .update(update)
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Stream<ProfileModel> getProfileStream(String userId) {
    return _client
        .from(AppConstants.profilesTable)
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) {
          if (rows.isEmpty) throw NotFoundException('Profile not found.');
          return ProfileModel.fromMap(rows.first);
        });
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(
    ProfileRemoteDataSourceRef ref) {
  return ProfileRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}
