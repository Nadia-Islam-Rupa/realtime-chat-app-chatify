import '../../domain/entities/conversation.dart';
import '../../../profile/domain/entities/profile.dart';

/// Data-layer model mapping between the `conversations` Supabase table
/// and the [Conversation] domain entity.
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.participantOne,
    required super.participantTwo,
    super.lastMessage,
    super.lastMessageAt,
    super.lastMessageBy,
    required super.createdAt,
    super.otherParticipant,
    super.unreadCount,
  });

  factory ConversationModel.fromMap(
    Map<String, dynamic> map, {
    Profile? otherParticipant,
    int unreadCount = 0,
  }) {
    return ConversationModel(
      id: map['id'] as String,
      participantOne: map['participant_one'] as String,
      participantTwo: map['participant_two'] as String,
      lastMessage: map['last_message'] as String?,
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'] as String)
          : null,
      lastMessageBy: map['last_message_by'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      otherParticipant: otherParticipant,
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participant_one': participantOne,
      'participant_two': participantTwo,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_by': lastMessageBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Conversation toEntity() => Conversation(
        id: id,
        participantOne: participantOne,
        participantTwo: participantTwo,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        lastMessageBy: lastMessageBy,
        createdAt: createdAt,
        otherParticipant: otherParticipant,
        unreadCount: unreadCount,
      );
}
