import '../../domain/entities/message.dart';

/// Data-layer model mapping between the `messages` Supabase table and [Message].
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    super.content,
    super.mediaUrl,
    super.mediaType,
    required super.isRead,
    required super.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      senderId: map['sender_id'] as String,
      content: map['content'] as String?,
      mediaUrl: map['media_url'] as String?,
      mediaType: _parseMediaType(map['media_type'] as String?),
      isRead: (map['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType == MediaType.none ? null : mediaType.name,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Message toEntity() => Message(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        isRead: isRead,
        createdAt: createdAt,
      );

  static MediaType _parseMediaType(String? raw) {
    if (raw == null) return MediaType.none;
    return MediaType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => MediaType.none,
    );
  }
}
