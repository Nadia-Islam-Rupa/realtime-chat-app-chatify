// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$friendsListHash() => r'4d42b5e3175e2c09fcdb582a9d1e023a70b3f24b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [friendsList].
@ProviderFor(friendsList)
const friendsListProvider = FriendsListFamily();

/// See also [friendsList].
class FriendsListFamily extends Family<AsyncValue<List<Friend>>> {
  /// See also [friendsList].
  const FriendsListFamily();

  /// See also [friendsList].
  FriendsListProvider call(String userId) {
    return FriendsListProvider(userId);
  }

  @override
  FriendsListProvider getProviderOverride(
    covariant FriendsListProvider provider,
  ) {
    return call(provider.userId);
  }

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

/// See also [friendsList].
class FriendsListProvider extends AutoDisposeStreamProvider<List<Friend>> {
  /// See also [friendsList].
  FriendsListProvider(String userId)
    : this._internal(
        (ref) => friendsList(ref as FriendsListRef, userId),
        from: friendsListProvider,
        name: r'friendsListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$friendsListHash,
        dependencies: FriendsListFamily._dependencies,
        allTransitiveDependencies: FriendsListFamily._allTransitiveDependencies,
        userId: userId,
      );

  FriendsListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<Friend>> Function(FriendsListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FriendsListProvider._internal(
        (ref) => create(ref as FriendsListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Friend>> createElement() {
    return _FriendsListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendsListProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FriendsListRef on AutoDisposeStreamProviderRef<List<Friend>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _FriendsListProviderElement
    extends AutoDisposeStreamProviderElement<List<Friend>>
    with FriendsListRef {
  _FriendsListProviderElement(super.provider);

  @override
  String get userId => (origin as FriendsListProvider).userId;
}

String _$pendingRequestsHash() => r'5295ab733c005351454674f95eb02078c12929fc';

/// See also [pendingRequests].
@ProviderFor(pendingRequests)
const pendingRequestsProvider = PendingRequestsFamily();

/// See also [pendingRequests].
class PendingRequestsFamily extends Family<AsyncValue<List<FriendRequest>>> {
  /// See also [pendingRequests].
  const PendingRequestsFamily();

  /// See also [pendingRequests].
  PendingRequestsProvider call(String userId) {
    return PendingRequestsProvider(userId);
  }

  @override
  PendingRequestsProvider getProviderOverride(
    covariant PendingRequestsProvider provider,
  ) {
    return call(provider.userId);
  }

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

/// See also [pendingRequests].
class PendingRequestsProvider
    extends AutoDisposeStreamProvider<List<FriendRequest>> {
  /// See also [pendingRequests].
  PendingRequestsProvider(String userId)
    : this._internal(
        (ref) => pendingRequests(ref as PendingRequestsRef, userId),
        from: pendingRequestsProvider,
        name: r'pendingRequestsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pendingRequestsHash,
        dependencies: PendingRequestsFamily._dependencies,
        allTransitiveDependencies:
            PendingRequestsFamily._allTransitiveDependencies,
        userId: userId,
      );

  PendingRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<FriendRequest>> Function(PendingRequestsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PendingRequestsProvider._internal(
        (ref) => create(ref as PendingRequestsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<FriendRequest>> createElement() {
    return _PendingRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingRequestsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PendingRequestsRef on AutoDisposeStreamProviderRef<List<FriendRequest>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _PendingRequestsProviderElement
    extends AutoDisposeStreamProviderElement<List<FriendRequest>>
    with PendingRequestsRef {
  _PendingRequestsProviderElement(super.provider);

  @override
  String get userId => (origin as PendingRequestsProvider).userId;
}

String _$sentRequestsHash() => r'331d1d81589ea64718e903de07be8d060a4473ff';

/// See also [sentRequests].
@ProviderFor(sentRequests)
const sentRequestsProvider = SentRequestsFamily();

/// See also [sentRequests].
class SentRequestsFamily extends Family<AsyncValue<List<FriendRequest>>> {
  /// See also [sentRequests].
  const SentRequestsFamily();

  /// See also [sentRequests].
  SentRequestsProvider call(String userId) {
    return SentRequestsProvider(userId);
  }

  @override
  SentRequestsProvider getProviderOverride(
    covariant SentRequestsProvider provider,
  ) {
    return call(provider.userId);
  }

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

/// See also [sentRequests].
class SentRequestsProvider
    extends AutoDisposeStreamProvider<List<FriendRequest>> {
  /// See also [sentRequests].
  SentRequestsProvider(String userId)
    : this._internal(
        (ref) => sentRequests(ref as SentRequestsRef, userId),
        from: sentRequestsProvider,
        name: r'sentRequestsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sentRequestsHash,
        dependencies: SentRequestsFamily._dependencies,
        allTransitiveDependencies:
            SentRequestsFamily._allTransitiveDependencies,
        userId: userId,
      );

  SentRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<FriendRequest>> Function(SentRequestsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SentRequestsProvider._internal(
        (ref) => create(ref as SentRequestsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<FriendRequest>> createElement() {
    return _SentRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SentRequestsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SentRequestsRef on AutoDisposeStreamProviderRef<List<FriendRequest>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _SentRequestsProviderElement
    extends AutoDisposeStreamProviderElement<List<FriendRequest>>
    with SentRequestsRef {
  _SentRequestsProviderElement(super.provider);

  @override
  String get userId => (origin as SentRequestsProvider).userId;
}

String _$allUsersHash() => r'a974223f72626f8e82a3e742c9cfebf3e056490f';

/// See also [allUsers].
@ProviderFor(allUsers)
const allUsersProvider = AllUsersFamily();

/// See also [allUsers].
class AllUsersFamily extends Family<AsyncValue<List<Profile>>> {
  /// See also [allUsers].
  const AllUsersFamily();

  /// See also [allUsers].
  AllUsersProvider call(String currentUserId) {
    return AllUsersProvider(currentUserId);
  }

  @override
  AllUsersProvider getProviderOverride(covariant AllUsersProvider provider) {
    return call(provider.currentUserId);
  }

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

/// See also [allUsers].
class AllUsersProvider extends AutoDisposeFutureProvider<List<Profile>> {
  /// See also [allUsers].
  AllUsersProvider(String currentUserId)
    : this._internal(
        (ref) => allUsers(ref as AllUsersRef, currentUserId),
        from: allUsersProvider,
        name: r'allUsersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allUsersHash,
        dependencies: AllUsersFamily._dependencies,
        allTransitiveDependencies: AllUsersFamily._allTransitiveDependencies,
        currentUserId: currentUserId,
      );

  AllUsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.currentUserId,
  }) : super.internal();

  final String currentUserId;

  @override
  Override overrideWith(
    FutureOr<List<Profile>> Function(AllUsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllUsersProvider._internal(
        (ref) => create(ref as AllUsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Profile>> createElement() {
    return _AllUsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllUsersProvider && other.currentUserId == currentUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, currentUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AllUsersRef on AutoDisposeFutureProviderRef<List<Profile>> {
  /// The parameter `currentUserId` of this provider.
  String get currentUserId;
}

class _AllUsersProviderElement
    extends AutoDisposeFutureProviderElement<List<Profile>>
    with AllUsersRef {
  _AllUsersProviderElement(super.provider);

  @override
  String get currentUserId => (origin as AllUsersProvider).currentUserId;
}

String _$userRelationHash() => r'4aeb9828f5b242de6da2ec0d84e334fb1d612eda';

/// Computes [RelationInfo] for a given [otherUserId] by reading the live
/// friends list, sent requests, and received requests already in the cache.
///
/// Copied from [userRelation].
@ProviderFor(userRelation)
const userRelationProvider = UserRelationFamily();

/// Computes [RelationInfo] for a given [otherUserId] by reading the live
/// friends list, sent requests, and received requests already in the cache.
///
/// Copied from [userRelation].
class UserRelationFamily extends Family<RelationInfo> {
  /// Computes [RelationInfo] for a given [otherUserId] by reading the live
  /// friends list, sent requests, and received requests already in the cache.
  ///
  /// Copied from [userRelation].
  const UserRelationFamily();

  /// Computes [RelationInfo] for a given [otherUserId] by reading the live
  /// friends list, sent requests, and received requests already in the cache.
  ///
  /// Copied from [userRelation].
  UserRelationProvider call(String currentUserId, String otherUserId) {
    return UserRelationProvider(currentUserId, otherUserId);
  }

  @override
  UserRelationProvider getProviderOverride(
    covariant UserRelationProvider provider,
  ) {
    return call(provider.currentUserId, provider.otherUserId);
  }

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

/// Computes [RelationInfo] for a given [otherUserId] by reading the live
/// friends list, sent requests, and received requests already in the cache.
///
/// Copied from [userRelation].
class UserRelationProvider extends AutoDisposeProvider<RelationInfo> {
  /// Computes [RelationInfo] for a given [otherUserId] by reading the live
  /// friends list, sent requests, and received requests already in the cache.
  ///
  /// Copied from [userRelation].
  UserRelationProvider(String currentUserId, String otherUserId)
    : this._internal(
        (ref) =>
            userRelation(ref as UserRelationRef, currentUserId, otherUserId),
        from: userRelationProvider,
        name: r'userRelationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userRelationHash,
        dependencies: UserRelationFamily._dependencies,
        allTransitiveDependencies:
            UserRelationFamily._allTransitiveDependencies,
        currentUserId: currentUserId,
        otherUserId: otherUserId,
      );

  UserRelationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.currentUserId,
    required this.otherUserId,
  }) : super.internal();

  final String currentUserId;
  final String otherUserId;

  @override
  Override overrideWith(
    RelationInfo Function(UserRelationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserRelationProvider._internal(
        (ref) => create(ref as UserRelationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        currentUserId: currentUserId,
        otherUserId: otherUserId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<RelationInfo> createElement() {
    return _UserRelationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRelationProvider &&
        other.currentUserId == currentUserId &&
        other.otherUserId == otherUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, currentUserId.hashCode);
    hash = _SystemHash.combine(hash, otherUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserRelationRef on AutoDisposeProviderRef<RelationInfo> {
  /// The parameter `currentUserId` of this provider.
  String get currentUserId;

  /// The parameter `otherUserId` of this provider.
  String get otherUserId;
}

class _UserRelationProviderElement
    extends AutoDisposeProviderElement<RelationInfo>
    with UserRelationRef {
  _UserRelationProviderElement(super.provider);

  @override
  String get currentUserId => (origin as UserRelationProvider).currentUserId;
  @override
  String get otherUserId => (origin as UserRelationProvider).otherUserId;
}

String _$findPeopleNotifierHash() =>
    r'2fa04f55da4ac36fdf66237233137136f8470b9a';

/// See also [FindPeopleNotifier].
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
String _$friendActionsNotifierHash() =>
    r'd13ada2979eb002708b745bd0a2f8e7c76d5b11a';

/// See also [FriendActionsNotifier].
@ProviderFor(FriendActionsNotifier)
final friendActionsNotifierProvider =
    AutoDisposeNotifierProvider<
      FriendActionsNotifier,
      FriendActionState
    >.internal(
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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
