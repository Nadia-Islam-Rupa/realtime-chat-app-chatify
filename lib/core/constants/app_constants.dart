/// Application-wide string and numeric constants.
/// Add values here as features are implemented.
abstract final class AppConstants {
  // --- App metadata ---
  static const String appName = 'Chatify';
  static const String appVersion = '1.0.0';

  // --- Supabase table names ---
  static const String profilesTable = 'profile';
  static const String friendRequestsTable = 'friend_requests';
  static const String friendsTable = 'friends';
  static const String blockedUsersTable = 'blocked_users';
  static const String conversationsTable = 'conversations';
  static const String messagesTable = 'messages';
  static const String typingStatusTable = 'typing_status';
  static const String loginHistoryTable = 'login_history';

  // --- Supabase storage buckets ---
  static const String avatarsBucket = 'avatars';
  static const String profileImagesBucket = 'profile-pictures';
  static const String chatMediaBucket = 'chat-media';

  // --- Pagination ---
  static const int defaultPageSize = 20;

  // --- Timeouts ---
  static const Duration networkTimeout = Duration(seconds: 15);
}
