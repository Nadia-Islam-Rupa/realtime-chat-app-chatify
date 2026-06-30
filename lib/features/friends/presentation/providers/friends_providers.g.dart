// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: deprecated_member_use

part of 'friends_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore: unused_element
String _$friendsListHash() => r'friends_list_hash';

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
  FriendsListProvider(this.userId) : super((ref) => friendsList(ref, userId));
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
String _$pendingRequestsHash() => r'pending_requests_hash';

@ProviderFor(pendingRequests)
const pendingRequestsProvider = PendingRequestsFamily();

class PendingRequestsFamily extends Family<AsyncValue<List<FriendRequest>>> {
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

typedef PendingRequestsRef = AutoDisposeStreamProviderRef<List<FriendRequest>>;

// ---------------------------------------------------------------------------

// ignore: unused_element
String _$sentRequestsHash() => r'sent_requests_hash';

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

// ignore: unused_element
String _$allUsersHash() => r'all_users_hash';

@ProviderFor(allUsers)
const allUsersProvider = AllUsersFamily();

class AllUsersFamily extends Family<AsyncValue<List<Profile>>> {
  const AllUsersFamily();
  AllUsersProvider call(String currentUserId) =>
      AllUsersProvider(currentUserId);
  @override
  AllUsersProvider getProviderOverride(covariant AllUsersProvider provider) =>
      call(provider.currentUserId);
  static const Iterable<ProviderOrFamily>? _dependencies = null;
  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;
  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;
  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;
  @override
  String? get name => r'allUsersProvider';
}

class AllUsersProvider extends AutoDisposeFutureProvider<List<Profile>> {
  AllUsersProvider(this.currentUserId)
      : super((ref) => allUsers(ref, currentUserId));
  final String currentUserId;
  @override
  bool operator ==(Object other) =>
      other is AllUsersProvider && other.currentUserId == currentUserId;
  @override
  int get hashCode => currentUserId.hashCode;
}

typedef AllUsersRef = AutoDisposeFutureProviderRef<List<Profile>>;

// ---------------------------------------------------------------------------

// ignore: unused_element
String _$userRelationHash() => r'user_relation_hash';

@ProviderFor(userRelation)
const userRelationProvider = UserRelationFamily();

class UserRelationFamily extends Family<RelationInfo> {
  const UserRelationFamily();
  UserRelationProvider call(String currentUserId, String otherUserId) =>
      UserRelationProvider(currentUserId, otherUserId);
  @override
  UserRelationProvider getProviderOverride(
          covariant UserRelationProvider provider) =>
      call(provider.currentUserId, provider.otherUserId);
  static const Iterable<ProviderOrFamily>? _dependencies = null;
  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;
  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;
  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;
  @override
  String? get name => r'userRelationProvider';
}

class UserRelationProvider extends AutoDisposeProvider<RelationInfo> {
  UserRelationProvider(this.currentUserId, this.otherUserId)
      : super((ref) => userRelation(ref, currentUserId, otherUserId));
  final String currentUserId;
  final String otherUserId;
  @override
  bool operator ==(Object other) =>
      other is UserRelationProvider &&
      other.currentUserId == currentUserId &&
      other.otherUserId == otherUserId;
  @override
  int get hashCode => Object.hash(currentUserId, otherUserId);
}

typedef UserRelationRef = AutoDisposeProviderRef<RelationInfo>;

// ---------------------------------------------------------------------------

String _$findPeopleNotifierHash() => r'find_people_notifier_hash';

@ProviderFor(FindPeopleNotifier)
final findPeopleNotifierProvider =
    AutoDisposeNotifierProvider<FindPeopleNotifier, FindPeopleState>.internal(
  FindPeopleNotifier.new,
  name: r'findPeopleNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$findPeopleNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FindPeopleNotifier = AutoDisposeNotifier<FindPeopleState>;

// ---------------------------------------------------------------------------

String _$friendActionsNotifierHash() => r'friend_actions_notifier_hash';

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
