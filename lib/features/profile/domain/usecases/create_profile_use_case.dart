import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class CreateProfileUseCase {
  final ProfileRepository _repository;
  const CreateProfileUseCase(this._repository);

  Future<Either<Failure, Profile>> call(Profile profile) {
    return _repository.createProfile(profile);
  }
}
