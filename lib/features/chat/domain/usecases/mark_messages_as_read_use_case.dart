import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class MarkMessagesAsReadUseCase {
  final ChatRepository _repository;
  const MarkMessagesAsReadUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String conversationId,
    String userId,
  ) =>
      _repository.markMessagesAsRead(conversationId, userId);
}
