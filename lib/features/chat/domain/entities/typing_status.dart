import 'package:equatable/equatable.dart';

/// Represents the typing state of a user within a conversation.
class TypingStatus extends Equatable {
  final String conversationId;
  final String userId;
  final bool isTyping;
  final DateTime updatedAt;

  const TypingStatus({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [conversationId, userId, isTyping, updatedAt];
}
