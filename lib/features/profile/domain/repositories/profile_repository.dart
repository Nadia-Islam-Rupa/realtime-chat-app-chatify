import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile.dart';

/// Domain contract for all profile operations.
abstract class ProfileRepository {
  /// Creates a new profile row in the database.
  Future<Either<Failure, Profile>> createProfile(Profile profile);

  /// Fetches a profile once by [userId].
  Future<Either<Failure, Profile>> getProfile(String userId);

  /// Updates an existing profile.
  Future<Either<Failure, Profile>> updateProfile(Profile profile);

  /// Uploads [image] to Supabase Storage and returns the public URL.
  Future<Either<Failure, String>> uploadProfileImage(File image, String userId);

  /// Sets the current user's online status and updates last_seen when going offline.
  Future<Either<Failure, void>> setOnlineStatus({
    required String userId,
    required bool isOnline,
  });

  /// A realtime stream of [Profile] for [userId], reflecting online/last_seen
  /// changes as they happen.
  Stream<Either<Failure, Profile>> getProfileStream(String userId);
}
