import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/typing_status.dart';

/// Contract for all chat-related data operations.
///
/// All stream-based methods return [Stream<Either<Failure, T>>] so that errors
/// are surfaced as domain failures rather than exceptions in the presentation
/// layer.  One-shot futures return [Future<Either<Failure, T>>].
abstract class ChatRepository {
  // ── Conversations ─────────────────────────────────────────────────────────

  /// Returns the existing conversation between the current user and
  /// [otherUserId], creating one if none exists.
  ///
  /// The check is order-insensitive:
  ///   (participant_one == me AND participant_two == other)
  ///   OR (participant_one == other AND participant_two == me)
  Future<Either<Failure, Conversation>> getOrCreateConversation(
    String otherUserId,
  );

  /// Streams all conversations for the current user ordered by
  /// [last_message_at] DESC.  Each [Conversation] includes the other
  /// participant's [Profile] and the per-user unread count.
  Stream<Either<Failure, List<Conversation>>> getConversationsList(
    String userId,
  );

  // ── Messages ──────────────────────────────────────────────────────────────

  /// Streams messages for [conversationId] ordered by [created_at] ASC.
  Stream<Either<Failure, List<Message>>> getMessages(String conversationId);

  /// Inserts a new text (or media) message and updates the conversation's
  /// [last_message] / [last_message_at] / [last_message_by] fields.
  Future<Either<Failure, Message>> sendMessage(
    String conversationId,
    String content, {
    String? mediaUrl,
    String? mediaType,
  });

  /// Marks all unread messages in [conversationId] as read for [userId].
  Future<Either<Failure, void>> markMessagesAsRead(
    String conversationId,
    String userId,
  );

  // ── Typing status ─────────────────────────────────────────────────────────

  /// Upserts the typing status for [userId] in [conversationId].
  Future<Either<Failure, void>> setTypingStatus(
    String conversationId,
    String userId, {
    required bool isTyping,
  });

  /// Streams typing-status rows for [conversationId] (all participants).
  Stream<Either<Failure, List<TypingStatus>>> getTypingStatus(
    String conversationId,
  );
}
