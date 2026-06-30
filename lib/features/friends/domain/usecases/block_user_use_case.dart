import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/friends_repository.dart';

class BlockUserUseCase {
  final FriendsRepository _repo;
  const BlockUserUseCase(this._repo);
  Future<Either<Failure, void>> call(String blockedId) =>
      _repo.blockUser(blockedId);
}
