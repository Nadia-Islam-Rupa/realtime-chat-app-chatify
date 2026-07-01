import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/profile.dart';

/// Represents a one-to-one conversation between two participants.
///
/// [otherParticipant] is populated at the presentation layer by joining
/// the conversations stream with the profiles table, so it is nullable here —
/// the domain entity stays clean of any UI concerns.
class Conversation extends Equatable {
  final String id;
  final String participantOne;
  final String participantTwo;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final DateTime createdAt;

  /// The other participant's profile — populated by the data layer join.
  final Profile? otherParticipant;

  /// How many unread messages the current user has in this conversation.
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.participantOne,
    required this.participantTwo,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageBy,
    required this.createdAt,
    this.otherParticipant,
    this.unreadCount = 0,
  });

  /// Returns the ID of the other participant given the current user's [myId].
  String otherUserId(String myId) =>
      participantOne == myId ? participantTwo : participantOne;

  Conversation copyWith({
    String? id,
    String? participantOne,
    String? participantTwo,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageBy,
    DateTime? createdAt,
    Profile? otherParticipant,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantOne: participantOne ?? this.participantOne,
      participantTwo: participantTwo ?? this.participantTwo,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageBy: lastMessageBy ?? this.lastMessageBy,
      createdAt: createdAt ?? this.createdAt,
      otherParticipant: otherParticipant ?? this.otherParticipant,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participantOne,
        participantTwo,
        lastMessage,
        lastMessageAt,
        lastMessageBy,
        createdAt,
        otherParticipant,
        unreadCount,
      ];
}
