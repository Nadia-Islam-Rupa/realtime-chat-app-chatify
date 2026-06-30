import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

part 'profile_repository_impl.g.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  const ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, Profile>> createProfile(Profile profile) async {
    try {
      final model = ProfileModel.fromEntity(profile);
      final result = await _dataSource.createProfile(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfile(String userId) async {
    try {
      final result = await _dataSource.getProfile(userId);
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile(Profile profile) async {
    try {
      final model = ProfileModel.fromEntity(profile);
      final result = await _dataSource.updateProfile(model);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(
    File image,
    String userId,
  ) async {
    try {
      final url = await _dataSource.uploadProfileImage(image, userId);
      return Right(url);
    } on StorageFailure catch (e) {
      return Left(StorageFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    try {
      await _dataSource.setOnlineStatus(userId: userId, isOnline: isOnline);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Profile>> getProfileStream(String userId) {
    return _dataSource
        .getProfileStream(userId)
        .map<Either<Failure, Profile>>((model) => Right(model.toEntity()))
        .handleError(
          (e) => Left(
            e is NotFoundException
                ? NotFoundFailure(e.message)
                : UnknownFailure(e.toString()),
          ),
        );
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
}
