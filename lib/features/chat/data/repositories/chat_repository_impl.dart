import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/typing_status.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

part 'chat_repository_impl.g.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _ds;
  final SupabaseClient _client;

  const ChatRepositoryImpl(this._ds, this._client);

  // ── Current user guard ─────────────────────────────────────────────────────
  String get _currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const UnauthenticatedException();
    return id;
  }

  // ── getOrCreateConversation ───────────────────────────────────────────────

  @override
  Future<Either<Failure, Conversation>> getOrCreateConversation(
    String otherUserId,
  ) async {
    try {
      final conversation = await _ds.getOrCreateConversation(
        _currentUserId,
        otherUserId,
      );
      return Right(conversation);
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── getConversationsList ──────────────────────────────────────────────────

  @override
  Stream<Either<Failure, List<Conversation>>> getConversationsList(
    String userId,
  ) {
    return _ds
        .getConversationsList(userId)
        .map<Either<Failure, List<Conversation>>>((list) => Right(list))
        .handleError(
          (e) => Left(_mapException(e)),
        );
  }

  // ── getMessages ───────────────────────────────────────────────────────────

  @override
  Stream<Either<Failure, List<Message>>> getMessages(String conversationId) {
    return _ds
        .getMessages(conversationId)
        .map<Either<Failure, List<Message>>>((list) => Right(list))
        .handleError(
          (e) => Left(_mapException(e)),
        );
  }

  // ── sendMessage ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Message>> sendMessage(
    String conversationId,
    String content, {
    String? mediaUrl,
    String? mediaType,
  }) async {
    try {
      final message = await _ds.sendMessage(
        conversationId,
        _currentUserId,
        content,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
      );
      return Right(message);
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── markMessagesAsRead ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      await _ds.markMessagesAsRead(conversationId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── setTypingStatus ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> setTypingStatus(
    String conversationId,
    String userId, {
    required bool isTyping,
  }) async {
    try {
      await _ds.setTypingStatus(
        conversationId,
        userId,
        isTyping: isTyping,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ── getTypingStatus ───────────────────────────────────────────────────────

  @override
  Stream<Either<Failure, List<TypingStatus>>> getTypingStatus(
    String conversationId,
  ) {
    return _ds
        .getTypingStatus(conversationId)
        .map<Either<Failure, List<TypingStatus>>>((list) => Right(list))
        .handleError(
          (e) => Left(_mapException(e)),
        );
  }

  // ── Error mapping ─────────────────────────────────────────────────────────

  Failure _mapException(dynamic e) {
    if (e is UnauthenticatedException) return const UnauthenticatedFailure();
    if (e is ServerException) return ServerFailure(e.message);
    if (e is StorageException) return StorageFailure(e.message);
    return UnknownFailure(e.toString());
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepositoryImpl(
    ref.watch(chatRemoteDataSourceProvider),
    ref.watch(supabaseClientProvider),
  );
}
