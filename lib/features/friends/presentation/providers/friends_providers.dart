import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/usecases/accept_friend_request_use_case.dart';
import '../../domain/usecases/cancel_friend_request_use_case.dart';
import '../../domain/usecases/reject_friend_request_use_case.dart';
import '../../domain/usecases/remove_friend_use_case.dart';
import '../../domain/usecases/search_users_by_name_use_case.dart';
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
      .map((either) => either.fold(
            (failure) => throw Exception(failure.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 2. Pending received requests stream
// ---------------------------------------------------------------------------

@riverpod
Stream<List<FriendRequest>> pendingRequests(
    PendingRequestsRef ref, String userId) {
  return ref
      .watch(friendsRepositoryProvider)
      .getPendingReceivedRequests(userId)
      .map((either) => either.fold(
            (failure) => throw Exception(failure.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 3. Sent (outgoing) requests stream
// ---------------------------------------------------------------------------

@riverpod
Stream<List<FriendRequest>> sentRequests(SentRequestsRef ref, String userId) {
  return ref
      .watch(friendsRepositoryProvider)
      .getSentRequests(userId)
      .map((either) => either.fold(
            (failure) => throw Exception(failure.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 4. Search users notifier
// ---------------------------------------------------------------------------

class SearchState {
  final String query;
  final bool isLoading;
  final List<Profile> results;
  final String? error;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.results = const [],
    this.error,
  });

  SearchState copyWith({
    String? query,
    bool? isLoading,
    List<Profile>? results,
    String? error,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class SearchUsersNotifier extends _$SearchUsersNotifier {
  @override
  SearchState build() => const SearchState();

  Future<void> search(String query) async {
    final trimmed = query.trim();
    state = state.copyWith(query: trimmed, clearError: true);

    if (trimmed.isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id ?? '';

    final result = await SearchUsersByNameUseCase(
      ref.read(friendsRepositoryProvider),
    )(trimmed, currentUserId);

    result.fold(
      (failure) => state =
          state.copyWith(isLoading: false, error: failure.message),
      (profiles) =>
          state = state.copyWith(isLoading: false, results: profiles),
    );
  }

  void clear() => state = const SearchState();
}

// ---------------------------------------------------------------------------
// 5. Friend action notifier (send / accept / reject / cancel / remove)
// ---------------------------------------------------------------------------

/// Holds last action result so the UI can show feedback.
class FriendActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const FriendActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  FriendActionState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    bool clear = false,
  }) {
    return FriendActionState(
      isLoading: isLoading ?? this.isLoading,
      error: clear ? null : (error ?? this.error),
      successMessage: clear ? null : (successMessage ?? this.successMessage),
    );
  }
}

@riverpod
class FriendActionsNotifier extends _$FriendActionsNotifier {
  @override
  FriendActionState build() => const FriendActionState();

  Future<bool> sendRequest(String receiverId) =>
      _run(() => SendFriendRequestUseCase(ref.read(friendsRepositoryProvider))(
            receiverId,
          ).then(
            (either) => either.fold(
              (f) => throw Exception(f.message),
              (_) => null,
            ),
          ), 'Friend request sent!');

  Future<bool> acceptRequest(String requestId) =>
      _run(() => AcceptFriendRequestUseCase(
            ref.read(friendsRepositoryProvider),
          )(requestId).then((either) => either.fold(
            (f) => throw Exception(f.message),
            (_) => null,
          )), 'Friend request accepted!');

  Future<bool> rejectRequest(String requestId) =>
      _run(() => RejectFriendRequestUseCase(
            ref.read(friendsRepositoryProvider),
          )(requestId).then((either) => either.fold(
            (f) => throw Exception(f.message),
            (_) => null,
          )), 'Request rejected.');

  Future<bool> cancelRequest(String requestId) =>
      _run(() => CancelFriendRequestUseCase(
            ref.read(friendsRepositoryProvider),
          )(requestId).then((either) => either.fold(
            (f) => throw Exception(f.message),
            (_) => null,
          )), 'Request cancelled.');

  Future<bool> removeFriend(String friendId) =>
      _run(() => RemoveFriendUseCase(
            ref.read(friendsRepositoryProvider),
          )(friendId).then((either) => either.fold(
            (f) => throw Exception(f.message),
            (_) => null,
          )), 'Friend removed.');

  Future<bool> _run(Future<void> Function() action, String success) async {
    state = state.copyWith(isLoading: true, clear: true);
    try {
      await action();
      state = state.copyWith(isLoading: false, successMessage: success);
      return true;
    } catch (e) {
      final msg = e is Failure ? e.message : e.toString();
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    }
  }
}
