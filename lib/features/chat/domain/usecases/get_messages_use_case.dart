import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository _repository;
  const GetMessagesUseCase(this._repository);

  Stream<Either<Failure, List<Message>>> call(String conversationId) =>
      _repository.getMessages(conversationId);
}
