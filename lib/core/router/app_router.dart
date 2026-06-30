import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/supabase_client_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/calls/presentation/screens/calls_history_screen.dart';
import '../../features/chat/presentation/screens/conversations_list_screen.dart';
import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/home/presentation/providers/home_tab_provider.dart';
import '../../features/home/presentation/screens/home_shell_screen.dart';
import '../../features/profile/domain/entities/profile.dart';
import '../../features/profile/presentation/screens/create_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/my_profile_tab_screen.dart';
import '../../features/profile/presentation/screens/profile_view_screen.dart';
import 'route_names.dart';

part 'app_router.g.dart';

// ---------------------------------------------------------------------------
// Profile existence check
// ---------------------------------------------------------------------------

/// Returns [true] if the given [userId] already has a profile row.
/// Used by the router redirect to decide whether to send a new user to
/// /create-profile or directly into the app.
@riverpod
Future<bool> profileExists(ProfileExistsRef ref, String userId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final result = await client
        .from(AppConstants.profilesTable)
        .select('id')
        .eq('id', userId)
        .maybeSingle();
    return result != null;
  } catch (_) {
    return false;
  }
}

// ---------------------------------------------------------------------------
// GoRouter refresh listenable — triggers redirect on auth state changes
// ---------------------------------------------------------------------------

class _SupabaseAuthNotifier with ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _SupabaseAuthNotifier(SupabaseClient client) {
    _sub = client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Placeholder screens (used until dedicated screens are built)
// ---------------------------------------------------------------------------

/// Temporary settings screen.
class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings — coming soon')),
    );
  }
}

/// Temporary chat/conversation screen.
/// Replace with the real ChatScreen once the chat feature is ready.
class _ChatScreen extends StatelessWidget {
  final String conversationId;
  const _ChatScreen({required this.conversationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat: $conversationId')),
      body: const Center(child: Text('Chat screen — coming soon')),
    );
  }
}

/// Temporary call screen.
class _CallScreen extends StatelessWidget {
  final String callId;
  const _CallScreen({required this.callId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Call: $callId')),
      body: const Center(child: Text('Call screen — coming soon')),
    );
  }
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final client = ref.watch(supabaseClientProvider);
  final notifier = _SupabaseAuthNotifier(client);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    // Default landing — will be redirected immediately
    initialLocation: RouteNames.signIn,
    debugLogDiagnostics: true,
    refreshListenable: notifier,

    // ── Global redirect guard ──────────────────────────────────────────────
    redirect: (context, state) async {
      final authAsync = ref.read(authStateProvider);
      final location = state.matchedLocation;

      // Wait for the auth stream to emit a value
      if (authAsync.isLoading) return null;

      final user = authAsync.valueOrNull;
      final isAuthenticated = user != null;
      final isOnAuthRoute =
          location == RouteNames.signIn || location == RouteNames.signUp;

      // ── Unauthenticated ──────────────────────────────────────────────────
      if (!isAuthenticated) {
        if (isOnAuthRoute) return null;
        return RouteNames.signIn;
      }

      // ── Authenticated on an auth route → check profile ───────────────────
      if (isOnAuthRoute) {
        final hasProfile =
            await ref.read(profileExistsProvider(user.id).future);
        return hasProfile ? RouteNames.chats : RouteNames.createProfile;
      }

      // ── Authenticated on /home → redirect to /home/chats ─────────────────
      if (location == RouteNames.home) {
        return RouteNames.chats;
      }

      // ── Prevent re-entering /create-profile once profile exists ───────────
      if (location == RouteNames.createProfile) {
        final hasProfile =
            await ref.read(profileExistsProvider(user.id).future);
        if (hasProfile) return RouteNames.chats;
      }

      return null;
    },

    routes: [
      // ── Auth routes (flat, no shell) ──────────────────────────────────────
      GoRoute(
        path: RouteNames.signIn,
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RouteNames.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteNames.createProfile,
        name: 'createProfile',
        builder: (context, state) => const CreateProfileScreen(),
      ),

      // ── Shell: HomeShellScreen wraps the 4 tab sub-routes ─────────────────
      //
      // ShellRoute provides a persistent shell widget (HomeShellScreen) around
      // the matched child route.  The bottom NavigationBar always stays visible
      // while navigating within /home/*.
      //
      // NOTE: We use an IndexedStack in HomeShellScreen rather than relying on
      // go_router's own child rendering — this keeps all 4 tab bodies alive and
      // preserves scroll state.  The ShellRoute child is received by the shell
      // but not rendered (it's ignored).  The active sub-route's sole purpose
      // is to keep the URL in sync with the tab so deep links and back-nav work.
      ShellRoute(
        builder: (context, state, child) =>
            HomeShellScreen(child: child),
        routes: [
          // /home — redirects to /home/chats via the global guard above
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            redirect: (context, state) => RouteNames.chats,
          ),

          // Tab 0 — Chats
          GoRoute(
            path: RouteNames.chats,
            name: 'chats',
            builder: (context, state) {
              // Sync the tab provider when navigating here directly
              // (e.g. back button, deep link)
              _syncTab(context, HomeTab.chats);
              return const ConversationsListScreen();
            },
          ),

          // Tab 1 — Friends
          GoRoute(
            path: RouteNames.friends,
            name: 'friends',
            builder: (context, state) {
              _syncTab(context, HomeTab.friends);
              return const FriendsScreen();
            },
          ),

          // Tab 2 — Calls
          GoRoute(
            path: RouteNames.calls,
            name: 'calls',
            builder: (context, state) {
              _syncTab(context, HomeTab.calls);
              return const CallsHistoryScreen();
            },
          ),

          // Tab 3 — My Profile
          GoRoute(
            path: RouteNames.myProfile,
            name: 'myProfile',
            builder: (context, state) {
              _syncTab(context, HomeTab.profile);
              return const MyProfileTabScreen();
            },
          ),
        ],
      ),

      // ── Pushed routes (outside the shell — bottom nav hidden) ─────────────

      // /chat/:conversationId
      GoRoute(
        path: RouteNames.chat,
        name: 'chat',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return _ChatScreen(conversationId: conversationId);
        },
      ),

      // /profile-view/:userId — another user's public profile
      GoRoute(
        path: RouteNames.profileView,
        name: 'profileView',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileViewScreen(userId: userId);
        },
      ),

      // /edit-profile — current user edits their own profile
      // Profile entity is passed via GoRouter's extra parameter
      GoRoute(
        path: RouteNames.editProfile,
        name: 'editProfile',
        builder: (context, state) {
          final profile = state.extra as Profile;
          return EditProfileScreen(profile: profile);
        },
      ),

      // /settings
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (_, _s) => const _SettingsScreen(),
      ),

      // /call/:callId
      GoRoute(
        path: RouteNames.call,
        name: 'call',
        builder: (context, state) {
          final callId = state.pathParameters['callId']!;
          return _CallScreen(callId: callId);
        },
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Helper — sync tab provider on direct navigation / deep link
// ---------------------------------------------------------------------------

/// Reads the Riverpod container from [context] and updates the
/// [homeTabNotifierProvider] to match [tab].
///
/// This handles the case where the user navigates to a tab route directly
/// (e.g. deep link, back button) without going through the NavigationBar,
/// so the selected-tab highlight stays in sync.
void _syncTab(BuildContext context, HomeTab tab) {
  // Schedule after the frame so the build phase is not disturbed
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Retrieve the ProviderContainer from the nearest ProviderScope
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(homeTabNotifierProvider.notifier).setTab(tab);
  });
}
