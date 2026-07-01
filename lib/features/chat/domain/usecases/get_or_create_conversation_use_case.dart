import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateConversationUseCase {
  final ChatRepository _repository;
  const GetOrCreateConversationUseCase(this._repository);

  Future<Either<Failure, Conversation>> call(String otherUserId) =>
      _repository.getOrCreateConversation(otherUserId);
}
