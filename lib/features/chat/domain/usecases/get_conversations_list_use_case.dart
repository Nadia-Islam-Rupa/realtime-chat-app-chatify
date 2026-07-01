import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationsListUseCase {
  final ChatRepository _repository;
  const GetConversationsListUseCase(this._repository);

  Stream<Either<Failure, List<Conversation>>> call(String userId) =>
      _repository.getConversationsList(userId);
}
