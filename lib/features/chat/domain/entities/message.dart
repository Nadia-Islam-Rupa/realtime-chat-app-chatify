import 'package:equatable/equatable.dart';

/// The type of media attached to a message.
enum MediaType { image, video, audio, file, none }

/// Represents a single chat message.
class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final String? mediaUrl;
  final MediaType mediaType;
  final bool isRead;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    this.mediaUrl,
    this.mediaType = MediaType.none,
    required this.isRead,
    required this.createdAt,
  });

  bool get hasMedia => mediaType != MediaType.none && mediaUrl != null;

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    String? mediaUrl,
    MediaType? mediaType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, conversationId, senderId, content, mediaUrl, mediaType, isRead, createdAt];
}
