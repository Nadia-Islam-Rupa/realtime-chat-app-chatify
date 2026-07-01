import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/entities/call.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/call_remote_data_source.dart';

part 'call_repository_impl.g.dart';

class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource _ds;
  final SupabaseClient _client;

  const CallRepositoryImpl(this._ds, this._client);

  String get _currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const UnauthenticatedException();
    return id;
  }

  @override
  Future<Either<Failure, Call>> initiateCall({
    required String calleeId,
    required CallType type,
    String? conversationId,
  }) async {
    try {
      final call = await _ds.initiateCall(
        callerId: _currentUserId,
        calleeId: calleeId,
        type: type,
        conversationId: conversationId,
      );
      return Right(call);
    } on UnauthenticatedException {
      return const Left(UnauthenticatedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptCall(String callId) async {
    try {
      await _ds.updateCallStatus(
        callId,
        CallStatus.accepted,
        acceptedAt: DateTime.now(),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectCall(String callId) async {
    try {
      await _ds.updateCallStatus(
        callId,
        CallStatus.rejected,
        endedAt: DateTime.now(),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endCall(String callId) async {
    try {
      await _ds.updateCallStatus(
        callId,
        CallStatus.ended,
        endedAt: DateTime.now(),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markMissed(String callId) async {
    try {
      await _ds.updateCallStatus(
        callId,
        CallStatus.missed,
        endedAt: DateTime.now(),
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Call>>> getCallHistory(String userId) {
    return _ds
        .getCallHistory(userId)
        .map<Either<Failure, List<Call>>>((list) => Right(list))
        .handleError((e) => Left(_map(e)));
  }

  @override
  Stream<Either<Failure, Call?>> getIncomingCall(String calleeId) {
    return _ds
        .getIncomingCall(calleeId)
        .map<Either<Failure, Call?>>((call) => Right(call))
        .handleError((e) => Left(_map(e)));
  }

  @override
  Future<Either<Failure, void>> sendSignal({
    required String callId,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _ds.sendSignal(callId: callId, event: event, payload: payload);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Map<String, dynamic>>> listenSignals(String callId) {
    return _ds
        .listenSignals(callId)
        .map<Either<Failure, Map<String, dynamic>>>(
            (payload) => Right(payload))
        .handleError((e) => Left(_map(e)));
  }

  Failure _map(dynamic e) {
    if (e is UnauthenticatedException) return const UnauthenticatedFailure();
    if (e is ServerException) return ServerFailure(e.message);
    return UnknownFailure(e.toString());
  }
}

@riverpod
CallRepository callRepository(CallRepositoryRef ref) {
  return CallRepositoryImpl(
    ref.watch(callRemoteDataSourceProvider),
    ref.watch(supabaseClientProvider),
  );
}
