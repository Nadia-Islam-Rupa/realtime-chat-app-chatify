import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/friends_repository.dart';

class CancelFriendRequestUseCase {
  final FriendsRepository _repo;
  const CancelFriendRequestUseCase(this._repo);
  Future<Either<Failure, void>> call(String requestId) =>
      _repo.cancelFriendRequest(requestId);
}
