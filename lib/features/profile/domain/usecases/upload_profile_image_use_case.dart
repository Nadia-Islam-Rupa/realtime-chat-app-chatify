import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/profile_repository.dart';

class UploadProfileImageUseCase {
  final ProfileRepository _repository;
  const UploadProfileImageUseCase(this._repository);

  Future<Either<Failure, String>> call(File image, String userId) {
    return _repository.uploadProfileImage(image, userId);
  }
}
