import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/friends_repository.dart';

class UnblockUserUseCase {
  final FriendsRepository _repo;
  const UnblockUserUseCase(this._repo);
  Future<Either<Failure, void>> call(String blockedId) =>
      _repo.unblockUser(blockedId);
}
