import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/blocked_user.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/repositories/friends_repository.dart';
import '../datasources/friends_remote_data_source.dart';

part 'friends_repository_impl.g.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource _ds;
  final SupabaseClient _client;

  const FriendsRepositoryImpl(this._ds, this._client);

  // ── Current authenticated user id ─────────────────────────────────────────
  String get _currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const UnauthenticatedException();
    return id;
  }

  // ── Streams ───────────────────────────────────────────────────────────────

  @override
  Stream<Either<Failure, List<Friend>>> getFriendsList(String userId) {
    return _ds
        .getFriendsList(userId)
        .map<Either<Failure, List<Friend>>>((list) => Right(list))
        .handleError((e) => Left(_mapException(e)));
  }

  @override
  Stream<Either<Failure, List<FriendRequest>>> getPendingReceivedRequests(
    String userId,
  ) {
    return _ds
        .getPendingReceivedRequests(userId)
        .map<Either<Failure, List<FriendRequest>>>((list) => Right(list))
        .handleError((e) => Left(_mapException(e)));
  }

  @override
  Stream<Either<Failure, List<FriendRequest>>> getSentRequests(String userId) {
    return _ds
        .getSentRequests(userId)
        .map<Either<Failure, List<FriendRequest>>>((list) => Right(list))
        .handleError((e) => Left(_mapException(e)));
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, FriendRequest>> sendFriendRequest(
    String receiverId,
  ) async {
    try {
      final result = await _ds.sendFriendRequest(_currentUserId, receiverId);
      return Right(result);
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnknownException catch (e) {
      return Left(UnknownFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptFriendRequest(String requestId) async {
    try {
      await _ds.acceptFriendRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectFriendRequest(String requestId) async {
    try {
      await _ds.rejectFriendRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelFriendRequest(String requestId) async {
    try {
      await _ds.cancelFriendRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriend(String friendId) async {
    try {
      await _ds.removeFriend(_currentUserId, friendId);
      return const Right(null);
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> blockUser(String blockedId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unblockUser(String blockedId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<BlockedUser>>> getBlockedUsers(
    String userId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Profile>>> searchUsersByName(
    String query,
    String currentUserId,
  ) async {
    try {
      final results = await _ds.searchUsersByName(query, currentUserId);
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getAllUsers(
    String currentUserId,
  ) async {
    try {
      final results = await _ds.getAllUsers(currentUserId);
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  Failure _mapException(dynamic e) {
    if (e is ServerException) return ServerFailure(e.message);
    if (e is UnauthenticatedException) return const UnauthenticatedFailure();
    return UnknownFailure(e.toString());
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
FriendsRepository friendsRepository(FriendsRepositoryRef ref) {
  return FriendsRepositoryImpl(
    ref.watch(friendsRemoteDataSourceProvider),
    ref.watch(supabaseClientProvider),
  );
}
