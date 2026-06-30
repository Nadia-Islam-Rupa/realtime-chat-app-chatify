import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../profile/domain/entities/profile.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/usecases/accept_friend_request_use_case.dart';
import '../../domain/usecases/cancel_friend_request_use_case.dart';
import '../../domain/usecases/reject_friend_request_use_case.dart';
import '../../domain/usecases/remove_friend_use_case.dart';
import '../../domain/usecases/send_friend_request_use_case.dart';

part 'friends_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Friends list stream
// ---------------------------------------------------------------------------

@riverpod
Stream<List<Friend>> friendsList(FriendsListRef ref, String userId) {
  return ref
      .watch(friendsRepositoryProvider)
      .getFriendsList(userId)
      .map(
        (either) =>
            either.fold((f) => throw Exception(f.message), (list) => list),
      );
}

// ---------------------------------------------------------------------------
// 2. Pending received requests stream
// ---------------------------------------------------------------------------

@riverpod
Stream<List<FriendRequest>> pendingRequests(
  PendingRequestsRef ref,
  String userId,
) {
  return ref
      .watch(friendsRepositoryProvider)
      .getPendingReceivedRequests(userId)
      .map(
        (either) =>
            either.fold((f) => throw Exception(f.message), (list) => list),
      );
}

// ---------------------------------------------------------------------------
// 3. Sent (outgoing) requests stream
// ---------------------------------------------------------------------------

@riverpod
Stream<List<FriendRequest>> sentRequests(SentRequestsRef ref, String userId) {
  return ref
      .watch(friendsRepositoryProvider)
      .getSentRequests(userId)
      .map(
        (either) =>
            either.fold((f) => throw Exception(f.message), (list) => list),
      );
}

// ---------------------------------------------------------------------------
// 4. All users (for Find People tab — loads everyone on open)
// ---------------------------------------------------------------------------

@riverpod
Future<List<Profile>> allUsers(AllUsersRef ref, String currentUserId) async {
  final result = await ref
      .watch(friendsRepositoryProvider)
      .getAllUsers(currentUserId);
  return result.fold((f) => throw Exception(f.message), (list) => list);
}

// ---------------------------------------------------------------------------
// 5. User relation — what is the relationship between me and [otherUserId]?
// ---------------------------------------------------------------------------

/// Describes the current relationship between the signed-in user and another.
enum UserRelation {
  none, // No connection — show "Add Friend"
  requestSent, // I sent them a pending request — show "Requested" + cancel
  requestReceived, // They sent me a pending request — show "Accept / Reject"
  friends, // Already friends — show "Friends"
}

class RelationInfo {
  final UserRelation relation;

  /// The request ID, populated when relation is [requestSent] or [requestReceived].
  final String? requestId;

  const RelationInfo({required this.relation, this.requestId});
}

/// Computes [RelationInfo] for a given [otherUserId] by reading the live
/// friends list, sent requests, and received requests already in the cache.
@riverpod
RelationInfo userRelation(
  UserRelationRef ref,
  String currentUserId,
  String otherUserId,
) {
  // Check if already friends
  final friendsAsync = ref.watch(friendsListProvider(currentUserId));
  final isFriend =
      friendsAsync.valueOrNull?.any((f) => f.friendId == otherUserId) ?? false;
  if (isFriend) return const RelationInfo(relation: UserRelation.friends);

  // Check if I sent them a pending request
  final sentAsync = ref.watch(sentRequestsProvider(currentUserId));
  final sentReq = sentAsync.valueOrNull
      ?.where((r) => r.receiverId == otherUserId)
      .firstOrNull;
  if (sentReq != null) {
    return RelationInfo(
      relation: UserRelation.requestSent,
      requestId: sentReq.id,
    );
  }

  // Check if they sent me a pending request
  final receivedAsync = ref.watch(pendingRequestsProvider(currentUserId));
  final receivedReq = receivedAsync.valueOrNull
      ?.where((r) => r.senderId == otherUserId)
      .firstOrNull;
  if (receivedReq != null) {
    return RelationInfo(
      relation: UserRelation.requestReceived,
      requestId: receivedReq.id,
    );
  }

  return const RelationInfo(relation: UserRelation.none);
}

// ---------------------------------------------------------------------------
// 6. Find People search notifier
//    Holds the current query string; actual filtering happens in the UI
//    against the [allUsersProvider] list so there's no extra network call.
// ---------------------------------------------------------------------------

class FindPeopleState {
  final String query;
  const FindPeopleState({this.query = ''});
  FindPeopleState withQuery(String q) => FindPeopleState(query: q.trim());
}

@riverpod
class FindPeopleNotifier extends _$FindPeopleNotifier {
  @override
  FindPeopleState build() => const FindPeopleState();

  void setQuery(String q) => state = state.withQuery(q);
  void clear() => state = const FindPeopleState();
}

// ---------------------------------------------------------------------------
// 7. Friend action notifier — per-user loading via a Set of in-flight IDs
// ---------------------------------------------------------------------------

class FriendActionState {
  /// Set of target user IDs (or request IDs) currently being actioned.
  final Set<String> loadingIds;
  final String? error;
  final String? successMessage;

  const FriendActionState({
    this.loadingIds = const {},
    this.error,
    this.successMessage,
  });

  bool isLoadingFor(String id) => loadingIds.contains(id);

  FriendActionState _addLoading(String id) => FriendActionState(
    loadingIds: {...loadingIds, id},
    error: null,
    successMessage: null,
  );

  FriendActionState _removeLoading(
    String id, {
    String? error,
    String? success,
  }) => FriendActionState(
    loadingIds: loadingIds.difference({id}),
    error: error,
    successMessage: success,
  );
}

@riverpod
class FriendActionsNotifier extends _$FriendActionsNotifier {
  @override
  FriendActionState build() => const FriendActionState();

  /// Send a friend request to [receiverId].
  Future<bool> sendRequest(String receiverId) async {
    state = state._addLoading(receiverId);
    final result = await SendFriendRequestUseCase(
      ref.read(friendsRepositoryProvider),
    )(receiverId);
    return result.fold(
      (f) {
        state = state._removeLoading(receiverId, error: f.message);
        return false;
      },
      (_) {
        state = state._removeLoading(
          receiverId,
          success: 'Friend request sent!',
        );
        return true;
      },
    );
  }

  /// Accept an incoming request. Use [requestId] for the action key.
  Future<bool> acceptRequest(String requestId) async {
    state = state._addLoading(requestId);
    final result = await AcceptFriendRequestUseCase(
      ref.read(friendsRepositoryProvider),
    )(requestId);
    return result.fold(
      (f) {
        state = state._removeLoading(requestId, error: f.message);
        return false;
      },
      (_) {
        state = state._removeLoading(
          requestId,
          success: 'Friend request accepted!',
        );
        return true;
      },
    );
  }

  /// Reject an incoming request.
  Future<bool> rejectRequest(String requestId) async {
    state = state._addLoading(requestId);
    final result = await RejectFriendRequestUseCase(
      ref.read(friendsRepositoryProvider),
    )(requestId);
    return result.fold(
      (f) {
        state = state._removeLoading(requestId, error: f.message);
        return false;
      },
      (_) {
        state = state._removeLoading(requestId, success: 'Request rejected.');
        return true;
      },
    );
  }

  /// Cancel a sent request. Use [requestId] as the loading key.
  Future<bool> cancelRequest(String requestId) async {
    state = state._addLoading(requestId);
    final result = await CancelFriendRequestUseCase(
      ref.read(friendsRepositoryProvider),
    )(requestId);
    return result.fold(
      (f) {
        state = state._removeLoading(requestId, error: f.message);
        return false;
      },
      (_) {
        state = state._removeLoading(requestId, success: 'Request cancelled.');
        return true;
      },
    );
  }

  /// Remove an existing friend. Use [friendId] as the loading key.
  Future<bool> removeFriend(String friendId) async {
    state = state._addLoading(friendId);
    final result = await RemoveFriendUseCase(
      ref.read(friendsRepositoryProvider),
    )(friendId);
    return result.fold(
      (f) {
        state = state._removeLoading(friendId, error: f.message);
        return false;
      },
      (_) {
        state = state._removeLoading(friendId, success: 'Friend removed.');
        return true;
      },
    );
  }
}
