import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class SetTypingStatusUseCase {
  final ChatRepository _repository;
  const SetTypingStatusUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String conversationId,
    String userId, {
    required bool isTyping,
  }) =>
      _repository.setTypingStatus(
        conversationId,
        userId,
        isTyping: isTyping,
      );
}
