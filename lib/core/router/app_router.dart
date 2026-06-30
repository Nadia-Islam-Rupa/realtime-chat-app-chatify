import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/supabase_client_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/friends/presentation/screens/friends_list_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/create_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_view_screen.dart';
import 'route_names.dart';

part 'app_router.g.dart';

// ---------------------------------------------------------------------------
// Profile existence check
// ---------------------------------------------------------------------------

/// Returns [true] if the `profile` table has a row for [userId].
/// Used by the router redirect to decide whether to send the user to
/// /create-profile or /home after sign-in.
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
// GoRouter refresh listenable backed by Supabase auth stream
// ---------------------------------------------------------------------------

/// A [ChangeNotifier] that notifies listeners whenever the Supabase auth
/// session changes. Passed to [GoRouter.refreshListenable] so the router
/// re-evaluates the redirect on every session event.
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
// Router
// ---------------------------------------------------------------------------

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final client = ref.watch(supabaseClientProvider);
  final notifier = _SupabaseAuthNotifier(client);

  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: RouteNames.signIn,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) async {
      final authAsync = ref.read(authStateProvider);
      final location = state.matchedLocation;

      // Auth stream still loading — stay on the current auth route.
      if (authAsync.isLoading) return null;

      final user = authAsync.valueOrNull;
      final isAuthenticated = user != null;

      final isOnAuthRoute =
          location == RouteNames.signIn || location == RouteNames.signUp;

      // --- Not signed in ---
      if (!isAuthenticated) {
        if (isOnAuthRoute) return null;
        return RouteNames.signIn;
      }

      // --- Signed in ---
      if (isOnAuthRoute) {
        final hasProfile = await ref.read(
          profileExistsProvider(user.id).future,
        );
        return hasProfile ? RouteNames.home : RouteNames.createProfile;
      }

      return null;
    },
    routes: [
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
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.chat,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: RouteNames.profileView,
        name: 'profileView',
        builder: (context, state) => const ProfileViewScreen(),
      ),
      GoRoute(
        path: RouteNames.friendsList,
        name: 'friendsList',
        builder: (context, state) => const FriendsListScreen(),
      ),
    ],
  );
}
