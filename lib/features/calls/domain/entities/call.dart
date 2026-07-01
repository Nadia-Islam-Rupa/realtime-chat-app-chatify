import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/profile.dart';

enum CallType { audio, video }

enum CallStatus { ringing, accepted, rejected, ended, missed }

/// Core domain entity representing a call record.
class Call extends Equatable {
  final String id;
  final String? conversationId;
  final String callerId;
  final String calleeId;
  final CallType type;
  final CallStatus status;
  final DateTime startedAt;
  final DateTime? acceptedAt;
  final DateTime? endedAt;

  /// Populated by the data layer — the other participant's profile.
  final Profile? otherProfile;

  const Call({
    required this.id,
    this.conversationId,
    required this.callerId,
    required this.calleeId,
    required this.type,
    required this.status,
    required this.startedAt,
    this.acceptedAt,
    this.endedAt,
    this.otherProfile,
  });

  /// Duration of the call. Only meaningful when [status] == accepted/ended.
  Duration? get duration {
    if (acceptedAt == null) return null;
    final end = endedAt ?? DateTime.now();
    return end.difference(acceptedAt!);
  }

  /// Whether this call is currently active (ringing or accepted).
  bool get isActive =>
      status == CallStatus.ringing || status == CallStatus.accepted;

  Call copyWith({
    String? id,
    String? conversationId,
    String? callerId,
    String? calleeId,
    CallType? type,
    CallStatus? status,
    DateTime? startedAt,
    DateTime? acceptedAt,
    DateTime? endedAt,
    Profile? otherProfile,
  }) {
    return Call(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      callerId: callerId ?? this.callerId,
      calleeId: calleeId ?? this.calleeId,
      type: type ?? this.type,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      endedAt: endedAt ?? this.endedAt,
      otherProfile: otherProfile ?? this.otherProfile,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        callerId,
        calleeId,
        type,
        status,
        startedAt,
        acceptedAt,
        endedAt,
      ];
}
