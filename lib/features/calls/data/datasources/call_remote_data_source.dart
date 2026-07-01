import 'dart:async';
import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/call.dart';
import '../models/call_model.dart';

part 'call_remote_data_source.g.dart';

// ---------------------------------------------------------------------------
// Contract
// ---------------------------------------------------------------------------

abstract class CallRemoteDataSource {
  Future<Call> initiateCall({
    required String callerId,
    required String calleeId,
    required CallType type,
    String? conversationId,
  });

  Future<void> updateCallStatus(
    String callId,
    CallStatus status, {
    DateTime? acceptedAt,
    DateTime? endedAt,
  });

  Stream<List<Call>> getCallHistory(String userId);

  Stream<Call?> getIncomingCall(String calleeId);

  Future<void> sendSignal({
    required String callId,
    required String event,
    required Map<String, dynamic> payload,
  });

  Stream<Map<String, dynamic>> listenSignals(String callId);
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class CallRemoteDataSourceImpl implements CallRemoteDataSource {
  final SupabaseClient _client;

  CallRemoteDataSourceImpl(this._client);

  // ── initiateCall ──────────────────────────────────────────────────────────

  @override
  Future<Call> initiateCall({
    required String callerId,
    required String calleeId,
    required CallType type,
    String? conversationId,
  }) async {
    try {
      final row = await _client
          .from(AppConstants.callsTable)
          .insert({
            'caller_id': callerId,
            'callee_id': calleeId,
            'type': type.name,
            'status': 'ringing',
            'conversation_id': ?conversationId,
          })
          .select()
          .single();

      final call = CallModel.fromMap(row);

      // Broadcast ringing event on the callee's personal notification channel
      // so their device wakes up immediately even before they join the call channel.
      await _client
          .channel('user_${calleeId}_calls')
          .sendBroadcastMessage(
            event: 'ringing',
            payload: {
              'call_id': call.id,
              'caller_id': callerId,
              'callee_id': calleeId,
              'type': type.name,
            },
          );

      return call;
    } on PostgrestException catch (e) {
      log('[CallDS] initiateCall: ${e.message}');
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── updateCallStatus ──────────────────────────────────────────────────────

  @override
  Future<void> updateCallStatus(
    String callId,
    CallStatus status, {
    DateTime? acceptedAt,
    DateTime? endedAt,
  }) async {
    try {
      final update = <String, dynamic>{'status': status.name};
      if (acceptedAt != null) {
        update['accepted_at'] = acceptedAt.toIso8601String();
      }
      if (endedAt != null) update['ended_at'] = endedAt.toIso8601String();

      await _client
          .from(AppConstants.callsTable)
          .update(update)
          .eq('id', callId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ── getCallHistory ────────────────────────────────────────────────────────

  @override
  Stream<List<Call>> getCallHistory(String userId) {
    final controller = StreamController<List<Call>>();
    RealtimeChannel? channel;

    Future<void> fetchAndEmit() async {
      if (controller.isClosed) return;
      try {
        final rows = await _client
            .from(AppConstants.callsTable)
            .select()
            .or('caller_id.eq.$userId,callee_id.eq.$userId')
            .order('started_at', ascending: false)
            .limit(50);

        final calls = await _enrichCalls(
          (rows as List).cast<Map<String, dynamic>>(),
          userId,
        );
        if (!controller.isClosed) controller.add(calls);
      } on PostgrestException catch (e) {
        if (!controller.isClosed) {
          controller.addError(ServerException(e.message));
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(UnknownException(e.toString()));
        }
      }
    }

    controller.onListen = () {
      fetchAndEmit();
      channel = _client
          .channel('call_history_$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.callsTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'caller_id',
              value: userId,
            ),
            callback: (_) => fetchAndEmit(),
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.callsTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'callee_id',
              value: userId,
            ),
            callback: (_) => fetchAndEmit(),
          )
          .subscribe();
    };

    controller.onCancel = () {
      channel?.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  Future<List<Call>> _enrichCalls(
    List<Map<String, dynamic>> rows,
    String userId,
  ) async {
    if (rows.isEmpty) return [];

    final otherIds = rows
        .map((r) {
          final caller = r['caller_id'] as String;
          return caller == userId ? r['callee_id'] as String : caller;
        })
        .toSet()
        .toList();

    final profileRows = await _client
        .from(AppConstants.profilesTable)
        .select()
        .inFilter('id', otherIds);

    final profileMap = <String, Profile>{
      for (final p in (profileRows as List).cast<Map<String, dynamic>>())
        p['id'] as String: ProfileModel.fromMap(p),
    };

    return rows.map((r) {
      final caller = r['caller_id'] as String;
      final otherId = caller == userId ? r['callee_id'] as String : caller;
      return CallModel.fromMap(r, otherProfile: profileMap[otherId]);
    }).toList();
  }

  // ── getIncomingCall ───────────────────────────────────────────────────────

  @override
  Stream<Call?> getIncomingCall(String calleeId) {
    final controller = StreamController<Call?>();
    RealtimeChannel? channel;

    Future<void> fetchAndEmit() async {
      if (controller.isClosed) return;
      try {
        final rows = await _client
            .from(AppConstants.callsTable)
            .select()
            .eq('callee_id', calleeId)
            .eq('status', 'ringing')
            .order('started_at', ascending: false)
            .limit(1);

        final list = (rows as List).cast<Map<String, dynamic>>();
        if (list.isEmpty) {
          if (!controller.isClosed) controller.add(null);
          return;
        }

        // Load caller profile
        final callerId = list.first['caller_id'] as String;
        final profileRow = await _client
            .from(AppConstants.profilesTable)
            .select()
            .eq('id', callerId)
            .maybeSingle();

        final profile = profileRow != null
            ? ProfileModel.fromMap(profileRow)
            : null;
        final call = CallModel.fromMap(list.first, otherProfile: profile);
        if (!controller.isClosed) controller.add(call);
      } on PostgrestException catch (e) {
        if (!controller.isClosed) {
          controller.addError(ServerException(e.message));
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(UnknownException(e.toString()));
        }
      }
    }

    controller.onListen = () {
      fetchAndEmit();

      // Listen on callee's personal notification channel for instant ringing
      channel = _client
          .channel('user_${calleeId}_calls')
          .onBroadcast(event: 'ringing', callback: (_) => fetchAndEmit())
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: AppConstants.callsTable,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'callee_id',
              value: calleeId,
            ),
            callback: (_) => fetchAndEmit(),
          )
          .subscribe();
    };

    controller.onCancel = () {
      channel?.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }

  // ── WebRTC Signaling via Broadcast ────────────────────────────────────────

  @override
  Future<void> sendSignal({
    required String callId,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _client
          .channel('call_$callId')
          .sendBroadcastMessage(event: event, payload: payload);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Stream<Map<String, dynamic>> listenSignals(String callId) {
    final controller = StreamController<Map<String, dynamic>>();
    RealtimeChannel? channel;

    controller.onListen = () {
      channel = _client.channel('call_$callId');

      for (final event in [
        'offer',
        'answer',
        'ice',
        'accept',
        'reject',
        'hangup',
      ]) {
        channel!.onBroadcast(
          event: event,
          callback: (payload) {
            if (!controller.isClosed) {
              controller.add({'event': event, ...payload});
            }
          },
        );
      }

      channel!.subscribe();
    };

    controller.onCancel = () {
      channel?.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
CallRemoteDataSource callRemoteDataSource(CallRemoteDataSourceRef ref) {
  return CallRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}
