import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../features/profile/domain/entities/profile.dart';
import '../entities/blocked_user.dart';
import '../entities/friend.dart';
import '../entities/friend_request.dart';

abstract class FriendsRepository {
  Future<Either<Failure, FriendRequest>> sendFriendRequest(String receiverId);
  Future<Either<Failure, void>> acceptFriendRequest(String requestId);
  Future<Either<Failure, void>> rejectFriendRequest(String requestId);
  Future<Either<Failure, void>> cancelFriendRequest(String requestId);
  Future<Either<Failure, void>> removeFriend(String friendId);
  Future<Either<Failure, void>> blockUser(String blockedId);
  Future<Either<Failure, void>> unblockUser(String blockedId);
  Stream<Either<Failure, List<Friend>>> getFriendsList(String userId);
  Stream<Either<Failure, List<FriendRequest>>> getPendingReceivedRequests(
      String userId);
  Stream<Either<Failure, List<FriendRequest>>> getSentRequests(String userId);
  Future<Either<Failure, List<BlockedUser>>> getBlockedUsers(String userId);
  Future<Either<Failure, List<Profile>>> searchUsersByName(
      String query, String currentUserId);
}
