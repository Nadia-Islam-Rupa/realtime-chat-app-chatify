/// Named route constants used throughout the app.
/// Always reference these instead of raw strings to avoid typos.
///
/// STRUCTURE:
///   Auth routes          — flat, outside any shell
///   Shell tab routes     — live inside HomeShellScreen (/home/*)
///   Pushed routes        — pushed on top of the shell (bottom nav hidden)
abstract final class RouteNames {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String createProfile = '/create-profile';

  // ── Shell root (redirects to /home/chats) ─────────────────────────────────
  static const String home = '/home';

  // ── Shell tab sub-routes ───────────────────────────────────────────────────
  static const String chats = '/home/chats';
  static const String friends = '/home/friends';
  static const String calls = '/home/calls';
  static const String myProfile = '/home/profile';

  // ── Pushed routes (outside the shell — bottom nav hidden) ─────────────────
  /// Individual chat conversation: /chat/:conversationId
  static const String chat = '/chat/:conversationId';

  /// Another user's profile view: /profile-view/:userId
  static const String profileView = '/profile-view/:userId';

  /// Current user edit profile (no params, profile passed via extra)
  static const String editProfile = '/edit-profile';

  /// Settings screen
  static const String settings = '/settings';

  /// Active call screen: /call/:callId
  static const String call = '/call/:callId';

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Build the concrete path for a chat conversation.
  static String chatPath(String conversationId) => '/chat/$conversationId';

  /// Build the concrete path for a user's profile view.
  static String profileViewPath(String userId) => '/profile-view/$userId';

  /// Build the concrete path for a call screen.
  static String callPath(String callId) => '/call/$callId';
}
