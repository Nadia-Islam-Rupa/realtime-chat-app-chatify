import '../../domain/entities/typing_status.dart';

/// Data-layer model mapping between the `typing_status` Supabase table and
/// the [TypingStatus] domain entity.
class TypingStatusModel extends TypingStatus {
  const TypingStatusModel({
    required super.conversationId,
    required super.userId,
    required super.isTyping,
    required super.updatedAt,
  });

  factory TypingStatusModel.fromMap(Map<String, dynamic> map) {
    return TypingStatusModel(
      conversationId: map['conversation_id'] as String,
      userId: map['user_id'] as String,
      isTyping: (map['is_typing'] as bool?) ?? false,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversation_id': conversationId,
      'user_id': userId,
      'is_typing': isTyping,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
