import '../../domain/entities/call.dart';
import '../../../profile/domain/entities/profile.dart';

class CallModel extends Call {
  const CallModel({
    required super.id,
    super.conversationId,
    required super.callerId,
    required super.calleeId,
    required super.type,
    required super.status,
    required super.startedAt,
    super.acceptedAt,
    super.endedAt,
    super.otherProfile,
  });

  factory CallModel.fromMap(
    Map<String, dynamic> map, {
    Profile? otherProfile,
  }) {
    return CallModel(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String?,
      callerId: map['caller_id'] as String,
      calleeId: map['callee_id'] as String,
      type: map['type'] == 'video' ? CallType.video : CallType.audio,
      status: _parseStatus(map['status'] as String),
      startedAt: DateTime.parse(map['started_at'] as String),
      acceptedAt: map['accepted_at'] != null
          ? DateTime.parse(map['accepted_at'] as String)
          : null,
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      otherProfile: otherProfile,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'conversation_id': conversationId,
        'caller_id': callerId,
        'callee_id': calleeId,
        'type': type.name,
        'status': status.name,
        'started_at': startedAt.toIso8601String(),
        'accepted_at': acceptedAt?.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
      };

  static CallStatus _parseStatus(String s) => switch (s) {
        'accepted' => CallStatus.accepted,
        'rejected' => CallStatus.rejected,
        'ended' => CallStatus.ended,
        'missed' => CallStatus.missed,
        _ => CallStatus.ringing,
      };
}
