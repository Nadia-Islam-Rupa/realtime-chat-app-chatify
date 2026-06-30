import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/friends_repository.dart';

class RemoveFriendUseCase {
  final FriendsRepository _repo;
  const RemoveFriendUseCase(this._repo);
  Future<Either<Failure, void>> call(String friendId) =>
      _repo.removeFriend(friendId);
}
