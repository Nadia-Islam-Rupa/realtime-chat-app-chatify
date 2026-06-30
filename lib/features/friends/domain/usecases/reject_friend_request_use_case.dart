import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/friends_repository.dart';

class RejectFriendRequestUseCase {
  final FriendsRepository _repo;
  const RejectFriendRequestUseCase(this._repo);
  Future<Either<Failure, void>> call(String requestId) =>
      _repo.rejectFriendRequest(requestId);
}
