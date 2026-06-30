import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/friend_request.dart';
import '../repositories/friends_repository.dart';

class SendFriendRequestUseCase {
  final FriendsRepository _repo;
  const SendFriendRequestUseCase(this._repo);
  Future<Either<Failure, FriendRequest>> call(String receiverId) =>
      _repo.sendFriendRequest(receiverId);
}
