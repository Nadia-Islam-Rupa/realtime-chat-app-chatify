import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;
  const SendMessageUseCase(this._repository);

  Future<Either<Failure, Message>> call(
    String conversationId,
    String content, {
    String? mediaUrl,
    String? mediaType,
  }) =>
      _repository.sendMessage(
        conversationId,
        content,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
      );
}
