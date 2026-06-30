import 'package:equatable/equatable.dart';

class Friend extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final DateTime createdAt;

  const Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, friendId, createdAt];
}
