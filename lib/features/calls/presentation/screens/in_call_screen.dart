import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/call.dart';
import '../providers/call_providers.dart';

/// Active in-call screen.
/// Pushed onto the stack when a call is accepted (by either party).
/// Pops itself when the session transitions to [WebRtcSessionState.ended].
class InCallScreen extends ConsumerStatefulWidget {
  final String callId;
  const InCallScreen({super.key, required this.callId});

  @override
  ConsumerState<InCallScreen> createState() => _InCallScreenState();
}

class _InCallScreenState extends ConsumerState<InCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _startTimer();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _startTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(webRtcSessionNotifierProvider);
    final call = session.call;
    final isVideo = call?.type == CallType.video;

    // Attach streams to renderers
    if (session.localStream != null) {
      _localRenderer.srcObject = session.localStream;
    }
    if (session.remoteStream != null) {
      _remoteRenderer.srcObject = session.remoteStream;
    }

    // Auto-pop when call ends
    ref.listen(webRtcSessionNotifierProvider, (prev, next) {
      if (next.state == WebRtcSessionState.ended ||
          next.state == WebRtcSessionState.idle) {
        if (context.mounted) Navigator.of(context).pop();
      }
    });

    final other = call?.otherProfile;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Remote video (full screen) ─────────────────────────────
            if (isVideo && session.remoteStream != null)
              Positioned.fill(
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            else
              // Audio call or no remote stream yet — show avatar
              Positioned.fill(
                child: _AudioCallBackground(
                  name: other?.name ?? 'Calling…',
                  imageUrl: other?.imageUrl,
                  status: _callStatusLabel(session.state),
                ),
              ),

            // ── Local video (PiP) ──────────────────────────────────────
            if (isVideo && session.localStream != null && !session.isCameraOff)
              Positioned(
                right: 16,
                top: 16,
                width: 100,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),

            // ── Top bar: name + timer ──────────────────────────────────
            Positioned(
              top: 16,
              left: 16,
              right: isVideo ? 132 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    other?.name ?? '…',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.state == WebRtcSessionState.connected
                        ? _formatDuration(_elapsed)
                        : _callStatusLabel(session.state),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // ── Control buttons ────────────────────────────────────────
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _ControlBar(isVideo: isVideo),
            ),
          ],
        ),
      ),
    );
  }

  String _callStatusLabel(WebRtcSessionState s) => switch (s) {
        WebRtcSessionState.requesting => 'Ringing…',
        WebRtcSessionState.ringing => 'Incoming…',
        WebRtcSessionState.connecting => 'Connecting…',
        WebRtcSessionState.connected => 'Connected',
        WebRtcSessionState.ended => 'Call ended',
        WebRtcSessionState.idle => '',
      };
}

// ---------------------------------------------------------------------------
// Audio call background
// ---------------------------------------------------------------------------

class _AudioCallBackground extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String status;
  const _AudioCallBackground({
    required this.name,
    required this.imageUrl,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 72,
              backgroundColor: AppColors.primaryLight,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              child: imageUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 52,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Control bar
// ---------------------------------------------------------------------------

class _ControlBar extends ConsumerWidget {
  final bool isVideo;
  const _ControlBar({required this.isVideo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(webRtcSessionNotifierProvider);
    final notifier = ref.read(webRtcSessionNotifierProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute
        _ControlButton(
          icon: session.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          label: session.isMuted ? 'Unmute' : 'Mute',
          onTap: notifier.toggleMute,
          active: session.isMuted,
        ),

        // Speaker
        _ControlButton(
          icon: session.isSpeakerOn
              ? Icons.volume_up_rounded
              : Icons.volume_down_rounded,
          label: session.isSpeakerOn ? 'Speaker' : 'Earpiece',
          onTap: notifier.toggleSpeaker,
          active: session.isSpeakerOn,
        ),

        // Camera (video only)
        if (isVideo)
          _ControlButton(
            icon: session.isCameraOff
                ? Icons.videocam_off_rounded
                : Icons.videocam_rounded,
            label: session.isCameraOff ? 'Camera off' : 'Camera',
            onTap: notifier.toggleCamera,
            active: !session.isCameraOff,
          ),

        // End call
        _ControlButton(
          icon: Icons.call_end_rounded,
          label: 'End',
          onTap: () => notifier.endCall(),
          isEndCall: true,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool isEndCall;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = true,
    this.isEndCall = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isEndCall
        ? const Color(0xFFE53935)
        : active
            ? Colors.white24
            : Colors.white12;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
