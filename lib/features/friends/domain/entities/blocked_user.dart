import 'package:equatable/equatable.dart';

class BlockedUser extends Equatable {
  final String id;
  final String blockerId;
  final String blockedId;
  final DateTime createdAt;

  const BlockedUser({
    required this.id,
    required this.blockerId,
    required this.blockedId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, blockerId, blockedId, createdAt];
}
