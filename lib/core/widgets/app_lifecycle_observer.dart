import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chatify/features/auth/presentation/providers/auth_providers.dart';
import 'package:chatify/features/profile/data/repositories/profile_repository_impl.dart';

/// Wraps the widget tree and observes app lifecycle changes.
///
/// When the app is resumed (foreground) → calls setOnlineStatus(true).
/// When the app is paused/detached (background) → calls setOnlineStatus(false)
/// and sets last_seen to now.
///
/// Place this as the direct child of [ProviderScope] → [MaterialApp].
class AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _setOnlineStatus(true);
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _setOnlineStatus(false);
    }
  }

  Future<void> _setOnlineStatus(bool isOnline) async {
    final userId = ref.read(authStateProvider).valueOrNull?.id;
    if (userId == null) return;
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.setOnlineStatus(userId: userId, isOnline: isOnline);
    } catch (_) {
      // Best-effort.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
