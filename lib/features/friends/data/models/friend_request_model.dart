import '../../domain/entities/friend_request.dart';

class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FriendRequestModel.fromMap(Map<String, dynamic> m) {
    return FriendRequestModel(
      id: m['id'] as String,
      senderId: m['sender_id'] as String,
      receiverId: m['receiver_id'] as String,
      status: _statusFromString(m['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(
          (m['updated_at'] ?? m['created_at']) as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'status': _statusToString(status),
      };

  static FriendRequestStatus _statusFromString(String s) {
    switch (s) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }

  static String _statusToString(FriendRequestStatus s) {
    switch (s) {
      case FriendRequestStatus.accepted:
        return 'accepted';
      case FriendRequestStatus.rejected:
        return 'rejected';
      case FriendRequestStatus.pending:
        return 'pending';
    }
  }
}
