import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/call.dart';
import '../providers/call_providers.dart';

/// Full-screen incoming call overlay shown when [incomingCallProvider] emits
/// a non-null ringing call.  Wrap the app's root widget with
/// [IncomingCallOverlay] so it appears above everything.
class IncomingCallOverlay extends ConsumerWidget {
  final Widget child;
  const IncomingCallOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingAsync = ref.watch(incomingCallProvider);
    final sessionState = ref.watch(webRtcSessionNotifierProvider).state;

    // Only show if a call is ringing AND we are not already in a call
    final incomingCall = incomingAsync.valueOrNull;
    final shouldShow = incomingCall != null &&
        incomingCall.status == CallStatus.ringing &&
        sessionState == WebRtcSessionState.idle;

    return Stack(
      children: [
        child,
        if (shouldShow)
          _IncomingCallScreen(call: incomingCall),
      ],
    );
  }
}

class _IncomingCallScreen extends ConsumerWidget {
  final Call call;
  const _IncomingCallScreen({required this.call});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final caller = call.otherProfile;
    final isVideo = call.type == CallType.video;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              // ── Call type label ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVideo
                          ? Icons.videocam_outlined
                          : Icons.call_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVideo ? 'Incoming video call' : 'Incoming voice call',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── Caller avatar ────────────────────────────────────────
              _PulsingAvatar(
                imageUrl: caller?.imageUrl,
                name: caller?.name ?? 'Unknown',
              ),

              const SizedBox(height: 24),

              // ── Caller name ──────────────────────────────────────────
              Text(
                caller?.name ?? 'Unknown',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'is calling you…',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white60,
                ),
              ),

              const Spacer(),

              // ── Action buttons ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reject
                    _CallActionButton(
                      icon: Icons.call_end_rounded,
                      color: const Color(0xFFE53935),
                      label: 'Decline',
                      onTap: () {
                        ref
                            .read(webRtcSessionNotifierProvider.notifier)
                            .rejectCall(call);
                      },
                    ),

                    // Accept
                    _CallActionButton(
                      icon: isVideo
                          ? Icons.videocam_rounded
                          : Icons.call_rounded,
                      color: AppColors.online,
                      label: 'Accept',
                      onTap: () {
                        ref
                            .read(webRtcSessionNotifierProvider.notifier)
                            .acceptCall(call);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing avatar
// ---------------------------------------------------------------------------

class _PulsingAvatar extends StatefulWidget {
  final String? imageUrl;
  final String name;
  const _PulsingAvatar({required this.imageUrl, required this.name});

  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(120),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 66,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: widget.imageUrl != null
              ? NetworkImage(widget.imageUrl!)
              : null,
          child: widget.imageUrl == null
              ? Text(
                  widget.name.isNotEmpty
                      ? widget.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 52,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Round call action button
// ---------------------------------------------------------------------------

class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(100),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
