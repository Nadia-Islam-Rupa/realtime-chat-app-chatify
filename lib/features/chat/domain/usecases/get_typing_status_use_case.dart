import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/typing_status.dart';
import '../repositories/chat_repository.dart';

class GetTypingStatusUseCase {
  final ChatRepository _repository;
  const GetTypingStatusUseCase(this._repository);

  Stream<Either<Failure, List<TypingStatus>>> call(String conversationId) =>
      _repository.getTypingStatus(conversationId);
}
