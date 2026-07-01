import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../friends/data/repositories/friends_repository_impl.dart';

part 'badge_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Unread conversation count — Chats tab badge
// ---------------------------------------------------------------------------

/// Streams the total number of unread messages across all conversations
/// for the current user.
@riverpod
Stream<int> unreadChatsCount(UnreadChatsCountRef ref) async* {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    yield 0;
    return;
  }

  yield* ref.watch(conversationsProvider.future).asStream().asyncExpand(
        (conversations) => Stream.value(
          conversations.fold(0, (sum, c) => sum + c.unreadCount),
        ),
      );
}

// ---------------------------------------------------------------------------
// 2. Pending incoming friend-request count — Friends tab badge
// ---------------------------------------------------------------------------

/// Streams the number of pending incoming friend requests for the current user.
/// Backed by [FriendsRepository.getPendingReceivedRequests] — updates live.
@riverpod
Stream<int> pendingFriendRequestCount(PendingFriendRequestCountRef ref) async* {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    yield 0;
    return;
  }

  yield* ref
      .watch(friendsRepositoryProvider)
      .getPendingReceivedRequests(user.id)
      .map((either) => either.fold((failure) => 0, (list) => list.length));
}
