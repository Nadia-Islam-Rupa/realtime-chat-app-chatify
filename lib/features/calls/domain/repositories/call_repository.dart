import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/call.dart';

abstract class CallRepository {
  /// Initiates a new call. Inserts a row in `calls` with status=ringing
  /// and broadcasts a `ringing` event on the call's Realtime channel.
  Future<Either<Failure, Call>> initiateCall({
    required String calleeId,
    required CallType type,
    String? conversationId,
  });

  /// Callee accepts the call. Updates status=accepted in `calls` and
  /// broadcasts `accept` on the Realtime channel.
  Future<Either<Failure, void>> acceptCall(String callId);

  /// Callee rejects the call. Updates status=rejected and broadcasts `reject`.
  Future<Either<Failure, void>> rejectCall(String callId);

  /// Either party ends the call. Updates status=ended + ended_at, broadcasts `hangup`.
  Future<Either<Failure, void>> endCall(String callId);

  /// Updates a stale ringing call to missed (called client-side on app resume).
  Future<Either<Failure, void>> markMissed(String callId);

  /// Streams the call history for [userId] ordered by started_at DESC.
  Stream<Either<Failure, List<Call>>> getCallHistory(String userId);

  /// Streams the currently ringing incoming call for [calleeId], if any.
  Stream<Either<Failure, Call?>> getIncomingCall(String calleeId);

  // ── WebRTC signaling via Realtime Broadcast ───────────────────────────────

  /// Sends a signaling event (offer/answer/ice/hangup/etc.) on the call channel.
  Future<Either<Failure, void>> sendSignal({
    required String callId,
    required String event,
    required Map<String, dynamic> payload,
  });

  /// Subscribes to signaling events for [callId].
  /// Emits raw payload maps — the WebRTC session notifier processes them.
  Stream<Either<Failure, Map<String, dynamic>>> listenSignals(String callId);
}
