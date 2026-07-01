import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/call.dart';
import '../repositories/call_repository.dart';

class InitiateCallUseCase {
  final CallRepository _repo;
  const InitiateCallUseCase(this._repo);

  Future<Either<Failure, Call>> call({
    required String calleeId,
    required CallType type,
    String? conversationId,
  }) =>
      _repo.initiateCall(
          calleeId: calleeId, type: type, conversationId: conversationId);
}

class AcceptCallUseCase {
  final CallRepository _repo;
  const AcceptCallUseCase(this._repo);
  Future<Either<Failure, void>> call(String callId) => _repo.acceptCall(callId);
}

class RejectCallUseCase {
  final CallRepository _repo;
  const RejectCallUseCase(this._repo);
  Future<Either<Failure, void>> call(String callId) => _repo.rejectCall(callId);
}

class EndCallUseCase {
  final CallRepository _repo;
  const EndCallUseCase(this._repo);
  Future<Either<Failure, void>> call(String callId) => _repo.endCall(callId);
}

class GetCallHistoryUseCase {
  final CallRepository _repo;
  const GetCallHistoryUseCase(this._repo);
  Stream<Either<Failure, List<Call>>> call(String userId) =>
      _repo.getCallHistory(userId);
}

class GetIncomingCallUseCase {
  final CallRepository _repo;
  const GetIncomingCallUseCase(this._repo);
  Stream<Either<Failure, Call?>> call(String calleeId) =>
      _repo.getIncomingCall(calleeId);
}

class SendSignalUseCase {
  final CallRepository _repo;
  const SendSignalUseCase(this._repo);
  Future<Either<Failure, void>> call({
    required String callId,
    required String event,
    required Map<String, dynamic> payload,
  }) =>
      _repo.sendSignal(callId: callId, event: event, payload: payload);
}

class ListenSignalsUseCase {
  final CallRepository _repo;
  const ListenSignalsUseCase(this._repo);
  Stream<Either<Failure, Map<String, dynamic>>> call(String callId) =>
      _repo.listenSignals(callId);
}
