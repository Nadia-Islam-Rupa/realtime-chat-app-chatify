import 'package:equatable/equatable.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, senderId, receiverId, status, createdAt, updatedAt];
}
