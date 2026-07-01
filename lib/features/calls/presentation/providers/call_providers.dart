import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/call_repository_impl.dart';
import '../../domain/entities/call.dart';
import '../../domain/usecases/call_use_cases.dart';

part 'call_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Call history stream
// ---------------------------------------------------------------------------

@riverpod
Stream<List<Call>> callHistory(CallHistoryRef ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);

  return GetCallHistoryUseCase(ref.watch(callRepositoryProvider))(user.id)
      .map((either) => either.fold(
            (f) => throw Exception(f.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 2. Incoming call stream
// ---------------------------------------------------------------------------

@riverpod
Stream<Call?> incomingCall(IncomingCallRef ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);

  return GetIncomingCallUseCase(ref.watch(callRepositoryProvider))(user.id)
      .map((either) => either.fold(
            (f) => throw Exception(f.message),
            (call) => call,
          ));
}

// ---------------------------------------------------------------------------
// 3. WebRTC session state
// ---------------------------------------------------------------------------

enum WebRtcSessionState {
  idle,
  requesting,   // caller: waiting for callee to pick up
  ringing,      // callee: incoming call overlay visible
  connecting,   // WebRTC negotiation in progress
  connected,    // media flowing
  ended,
}

class WebRtcSessionData {
  final WebRtcSessionState state;
  final Call? call;
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final RTCPeerConnection? peerConnection;
  final MediaStream? localStream;
  final MediaStream? remoteStream;
  final String? error;

  const WebRtcSessionData({
    this.state = WebRtcSessionState.idle,
    this.call,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = true,
    this.peerConnection,
    this.localStream,
    this.remoteStream,
    this.error,
  });

  bool get isActive =>
      state == WebRtcSessionState.requesting ||
      state == WebRtcSessionState.ringing ||
      state == WebRtcSessionState.connecting ||
      state == WebRtcSessionState.connected;

  WebRtcSessionData copyWith({
    WebRtcSessionState? state,
    Call? call,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeakerOn,
    RTCPeerConnection? peerConnection,
    MediaStream? localStream,
    MediaStream? remoteStream,
    String? error,
    bool clearCall = false,
    bool clearError = false,
  }) {
    return WebRtcSessionData(
      state: state ?? this.state,
      call: clearCall ? null : (call ?? this.call),
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      peerConnection: peerConnection ?? this.peerConnection,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. WebRTC Session Notifier
// ---------------------------------------------------------------------------

@riverpod
class WebRtcSessionNotifier extends _$WebRtcSessionNotifier {
  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  StreamSubscription<dynamic>? _signalSub;

  @override
  WebRtcSessionData build() => const WebRtcSessionData();

  // ── Caller: start a call ──────────────────────────────────────────────────

  Future<void> startCall({
    required String calleeId,
    required CallType type,
    String? conversationId,
  }) async {
    state = state.copyWith(
        state: WebRtcSessionState.requesting, clearError: true);

    // 1. Request permissions
    if (!await _requestPermissions(type)) {
      state = state.copyWith(
        state: WebRtcSessionState.idle,
        error: 'Camera/microphone permission denied',
      );
      return;
    }

    // 2. Insert call row in DB + broadcast ringing to callee
    final result = await InitiateCallUseCase(ref.read(callRepositoryProvider))(
      calleeId: calleeId,
      type: type,
      conversationId: conversationId,
    );

    if (result.isLeft()) {
      state = state.copyWith(
        state: WebRtcSessionState.idle,
        error: result.fold((f) => f.message, (_) => null),
      );
      return;
    }

    final call = result.getOrElse(() => throw StateError('unreachable'));
    state = state.copyWith(state: WebRtcSessionState.requesting, call: call);

    // 3. Acquire local media
    final localStream = await _getLocalStream(type);
    state = state.copyWith(localStream: localStream);

    // 4. Create peer connection and subscribe to signals
    await _setupPeerConnection(call.id, isCaller: true, type: type);

    // 5. Listen for callee's accept/reject/hangup signals
    _listenSignals(call.id);
  }

  // ── Callee: accept an incoming call ──────────────────────────────────────

  Future<void> acceptCall(Call call) async {
    state = state.copyWith(
        state: WebRtcSessionState.connecting, call: call, clearError: true);

    // 1. Request permissions
    if (!await _requestPermissions(call.type)) {
      state = state.copyWith(
        state: WebRtcSessionState.idle,
        error: 'Camera/microphone permission denied',
      );
      await _sendSignal(call.id, 'reject', {'call_id': call.id});
      return;
    }

    // 2. Update DB
    await AcceptCallUseCase(ref.read(callRepositoryProvider))(call.id);

    // 3. Acquire local media
    final localStream = await _getLocalStream(call.type);
    state = state.copyWith(localStream: localStream);

    // 4. Create peer connection
    await _setupPeerConnection(call.id, isCaller: false, type: call.type);

    // 5. Broadcast accept signal so caller knows we picked up
    await _sendSignal(call.id, 'accept', {'call_id': call.id});

    // 6. Listen for caller's offer and ICE candidates
    _listenSignals(call.id);
  }

  // ── Reject incoming call ──────────────────────────────────────────────────

  Future<void> rejectCall(Call call) async {
    await RejectCallUseCase(ref.read(callRepositoryProvider))(call.id);
    await _sendSignal(call.id, 'reject', {'call_id': call.id});
    state = const WebRtcSessionData(state: WebRtcSessionState.idle);
  }

  // ── End active call ───────────────────────────────────────────────────────

  Future<void> endCall() async {
    final callId = state.call?.id;
    if (callId != null) {
      await EndCallUseCase(ref.read(callRepositoryProvider))(callId);
      await _sendSignal(callId, 'hangup', {'call_id': callId});
    }
    await _cleanup();
  }

  // ── Media controls ────────────────────────────────────────────────────────

  void toggleMute() {
    final stream = state.localStream;
    if (stream == null) return;
    final newMuted = !state.isMuted;
    for (final track in stream.getAudioTracks()) {
      track.enabled = !newMuted;
    }
    state = state.copyWith(isMuted: newMuted);
  }

  void toggleCamera() {
    final stream = state.localStream;
    if (stream == null) return;
    final newOff = !state.isCameraOff;
    for (final track in stream.getVideoTracks()) {
      track.enabled = !newOff;
    }
    state = state.copyWith(isCameraOff: newOff);
  }

  void toggleSpeaker() {
    final newSpeaker = !state.isSpeakerOn;
    Helper.setSpeakerphoneOn(newSpeaker);
    state = state.copyWith(isSpeakerOn: newSpeaker);
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<bool> _requestPermissions(CallType type) async {
    final perms = <Permission>[Permission.microphone];
    if (type == CallType.video) perms.add(Permission.camera);
    final statuses = await perms.request();
    return statuses.values.every((s) => s == PermissionStatus.granted);
  }

  Future<MediaStream> _getLocalStream(CallType type) async {
    return navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': type == CallType.video
          ? {'facingMode': 'user', 'width': 640, 'height': 480}
          : false,
    });
  }

  Future<void> _setupPeerConnection(
    String callId, {
    required bool isCaller,
    required CallType type,
  }) async {
    final pc = await createPeerConnection(_iceServers);

    // Add local tracks
    final localStream = state.localStream;
    if (localStream != null) {
      for (final track in localStream.getTracks()) {
        await pc.addTrack(track, localStream);
      }
    }

    // Handle remote tracks
    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        state = state.copyWith(remoteStream: event.streams.first);
      }
    };

    // Send ICE candidates as they are gathered
    pc.onIceCandidate = (candidate) {
      _sendSignal(callId, 'ice', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    pc.onConnectionState = (connectionState) {
      if (connectionState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        state = state.copyWith(state: WebRtcSessionState.connected);
      } else if (connectionState ==
          RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _cleanup();
      }
    };

    state = state.copyWith(peerConnection: pc);

    // Caller creates and sends the offer
    if (isCaller) {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      await _sendSignal(callId, 'offer', {'sdp': offer.sdp, 'type': offer.type});
    }
  }

  void _listenSignals(String callId) {
    _signalSub?.cancel();
    _signalSub = ListenSignalsUseCase(ref.read(callRepositoryProvider))(callId)
        .listen((either) {
      either.fold(
        (f) => null, // ignore signal errors silently
        (payload) => _handleSignal(payload),
      );
    });
  }

  Future<void> _handleSignal(Map<String, dynamic> payload) async {
    final event = payload['event'] as String?;
    final pc = state.peerConnection;

    switch (event) {
      case 'accept':
        // Caller received accept — create and send offer if not already done
        // (offer was already sent in _setupPeerConnection for the caller)
        state = state.copyWith(state: WebRtcSessionState.connecting);

      case 'offer':
        if (pc == null) return;
        final sdp = payload['sdp'] as String?;
        final type = payload['type'] as String?;
        if (sdp == null || type == null) return;
        await pc.setRemoteDescription(RTCSessionDescription(sdp, type));
        final answer = await pc.createAnswer();
        await pc.setLocalDescription(answer);
        await _sendSignal(
          state.call!.id,
          'answer',
          {'sdp': answer.sdp, 'type': answer.type},
        );

      case 'answer':
        if (pc == null) return;
        final sdp = payload['sdp'] as String?;
        final type = payload['type'] as String?;
        if (sdp == null || type == null) return;
        await pc.setRemoteDescription(RTCSessionDescription(sdp, type));

      case 'ice':
        if (pc == null) return;
        final candidate = payload['candidate'] as String?;
        final sdpMid = payload['sdpMid'] as String?;
        final sdpMLineIndex = payload['sdpMLineIndex'];
        if (candidate == null) return;
        await pc.addCandidate(RTCIceCandidate(
          candidate,
          sdpMid,
          sdpMLineIndex is int ? sdpMLineIndex : int.tryParse('$sdpMLineIndex') ?? 0,
        ));

      case 'reject':
        await _cleanup();
        state = state.copyWith(
          state: WebRtcSessionState.ended,
          error: 'Call declined',
        );

      case 'hangup':
        await _cleanup();
    }
  }

  Future<void> _sendSignal(
    String callId,
    String event,
    Map<String, dynamic> payload,
  ) async {
    await SendSignalUseCase(ref.read(callRepositoryProvider))(
      callId: callId,
      event: event,
      payload: payload,
    );
  }

  Future<void> _cleanup() async {
    _signalSub?.cancel();
    _signalSub = null;

    await state.peerConnection?.close();
    await state.localStream?.dispose();
    await state.remoteStream?.dispose();

    state = const WebRtcSessionData(state: WebRtcSessionState.ended);

    // Small delay then go back to idle so UI can show "ended" briefly
    await Future.delayed(const Duration(seconds: 1));
    if (state.state == WebRtcSessionState.ended) {
      state = const WebRtcSessionData();
    }
  }
}
