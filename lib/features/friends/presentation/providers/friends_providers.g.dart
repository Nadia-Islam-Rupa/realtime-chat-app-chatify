// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: deprecated_member_use

part of 'friends_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore: unused_element
String _$friendsListHash() => r'friends_list_placeholder_hash';

@ProviderFor(friendsList)
const friendsListProvider = FriendsListFamily();

class FriendsListFamily extends Family<AsyncValue<List<Friend>>> {
  const FriendsListFamily();

  FriendsListProvider call(String userId) => FriendsListProvider(userId);

  @override
  FriendsListProvider getProviderOverride(
          covariant FriendsListProvider provider) =>
      call(provider.userId);

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'friendsListProvider';
}

class FriendsListProvider extends AutoDisposeStreamProvider<List<Friend>> {
  FriendsListProvider(this.userId)
      : super((ref) => friendsList(ref, userId));

  final String userId;

  @override
  bool operator ==(Object other) =>
      other is FriendsListProvider && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;
}

typedef FriendsListRef = AutoDisposeStreamProviderRef<List<Friend>>;

// ---------------------------------------------------------------------------

// ignore: unused_element
String _$pendingRequestsHash() => r'pending_requests_placeholder_hash';

@ProviderFor(pendingRequests)
const pendingRequestsProvider = PendingRequestsFamily();

class PendingRequestsFamily
    extends Family<AsyncValue<List<FriendRequest>>> {
  const PendingRequestsFamily();

  PendingRequestsProvider call(String userId) =>
      PendingRequestsProvider(userId);

  @override
  PendingRequestsProvider getProviderOverride(
          covariant PendingRequestsProvider provider) =>
      call(provider.userId);

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pendingRequestsProvider';
}

class PendingRequestsProvider
    extends AutoDisposeStreamProvider<List<FriendRequest>> {
  PendingRequestsProvider(this.userId)
      : super((ref) => pendingRequests(ref, userId));

  final String userId;

  @override
  bool operator ==(Object other) =>
      other is PendingRequestsProvider && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;
}

typedef PendingRequestsRef
    = AutoDisposeStreamProviderRef<List<FriendRequest>>;

// ---------------------------------------------------------------------------

// ignore: unused_element
String _$sentRequestsHash() => r'sent_requests_placeholder_hash';

@ProviderFor(sentRequests)
const sentRequestsProvider = SentRequestsFamily();

class SentRequestsFamily extends Family<AsyncValue<List<FriendRequest>>> {
  const SentRequestsFamily();

  SentRequestsProvider call(String userId) => SentRequestsProvider(userId);

  @override
  SentRequestsProvider getProviderOverride(
          covariant SentRequestsProvider provider) =>
      call(provider.userId);

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sentRequestsProvider';
}

class SentRequestsProvider
    extends AutoDisposeStreamProvider<List<FriendRequest>> {
  SentRequestsProvider(this.userId)
      : super((ref) => sentRequests(ref, userId));

  final String userId;

  @override
  bool operator ==(Object other) =>
      other is SentRequestsProvider && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;
}

typedef SentRequestsRef = AutoDisposeStreamProviderRef<List<FriendRequest>>;

// ---------------------------------------------------------------------------

String _$searchUsersNotifierHash() => r'search_users_notifier_placeholder';

@ProviderFor(SearchUsersNotifier)
final searchUsersNotifierProvider =
    AutoDisposeNotifierProvider<SearchUsersNotifier, SearchState>.internal(
  SearchUsersNotifier.new,
  name: r'searchUsersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchUsersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchUsersNotifier = AutoDisposeNotifier<SearchState>;

// ---------------------------------------------------------------------------

String _$friendActionsNotifierHash() => r'friend_actions_notifier_placeholder';

@ProviderFor(FriendActionsNotifier)
final friendActionsNotifierProvider = AutoDisposeNotifierProvider<
    FriendActionsNotifier, FriendActionState>.internal(
  FriendActionsNotifier.new,
  name: r'friendActionsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendActionsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FriendActionsNotifier = AutoDisposeNotifier<FriendActionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
