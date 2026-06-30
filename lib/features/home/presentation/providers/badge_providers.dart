import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

part 'badge_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Unread conversation count — Chats tab badge
// ---------------------------------------------------------------------------
//
// When the conversations data layer is fully built this provider will be
// replaced by the real unread-count stream.  For now it keeps the badge
// infrastructure in place and returns 0 so the tab renders without errors.
//
// Once the chat feature exposes an unreadCountProvider, swap the body of
// [unreadChatsCount] to:
//   return ref.watch(unreadCountProvider(userId));

/// Emits the number of conversations that have at least one unread message
/// for the currently signed-in user.
@riverpod
Stream<int> unreadChatsCount(UnreadChatsCountRef ref) async* {
  final authAsync = ref.watch(authStateProvider);
  final user = authAsync.valueOrNull;
  if (user == null) {
    yield 0;
    return;
  }

  // data source once it is implemented.
  //
  // Example when available:
  //   yield* ref.watch(unreadConversationCountProvider(user.id).stream);
  //
  // For now stream 0 indefinitely so the badge simply shows nothing.
  yield 0;
}

// ---------------------------------------------------------------------------
// 2. Pending incoming friend-request count — Friends tab badge
// ---------------------------------------------------------------------------

/// Emits the count of incoming (received) friend requests that are still
/// pending for the currently signed-in user.
///
/// Backed by [FriendsRepository.getPendingReceivedRequests] which is a
/// Supabase realtime stream, so this updates live when requests arrive or
/// are accepted/rejected.
@riverpod
Stream<int> pendingFriendRequestCount(PendingFriendRequestCountRef ref) async* {
  final authAsync = ref.watch(authStateProvider);
  final user = authAsync.valueOrNull;
  if (user == null) {
    yield 0;
    return;
  }

  // FriendsRepository is not yet injected via Riverpod in the friends feature,
  // so we read from Supabase directly here as a thin adapter.
  // When friends_repository_provider is wired up, replace this with:
  //   yield* ref
  //     .watch(friendsRepositoryProvider)
  //     .getPendingReceivedRequests(user.id)
  //     .map((either) => either.fold((_) => 0, (list) => list.length));

  final client = ref.watch(supabaseClientProvider);

  yield* client
      .from(AppConstants.friendRequestsTable)
      .stream(primaryKey: ['id'])
      .eq('receiver_id', user.id)
      .map((rows) => rows.where((r) => r['status'] == 'pending').length);
}
