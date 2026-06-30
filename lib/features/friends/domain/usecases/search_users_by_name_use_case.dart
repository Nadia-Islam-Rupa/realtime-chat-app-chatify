import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../features/profile/domain/entities/profile.dart';
import '../repositories/friends_repository.dart';

class SearchUsersByNameUseCase {
  final FriendsRepository _repo;
  const SearchUsersByNameUseCase(this._repo);
  Future<Either<Failure, List<Profile>>> call(
          String query, String currentUserId) =>
      _repo.searchUsersByName(query, currentUserId);
}
