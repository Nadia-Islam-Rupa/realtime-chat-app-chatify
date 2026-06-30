import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/friends_repository.dart';

class AcceptFriendRequestUseCase {
  final FriendsRepository _repo;
  const AcceptFriendRequestUseCase(this._repo);
  Future<Either<Failure, void>> call(String requestId) =>
      _repo.acceptFriendRequest(requestId);
}
