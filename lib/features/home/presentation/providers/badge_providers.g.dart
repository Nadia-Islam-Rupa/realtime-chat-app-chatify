// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadChatsCountHash() => r'2b14a285aaa29ee7cc2337f5f3128d8a9e05b2cd';

/// Streams the total number of unread messages across all conversations
/// for the current user.
///
/// Copied from [unreadChatsCount].
@ProviderFor(unreadChatsCount)
final unreadChatsCountProvider = AutoDisposeStreamProvider<int>.internal(
  unreadChatsCount,
  name: r'unreadChatsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadChatsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadChatsCountRef = AutoDisposeStreamProviderRef<int>;
String _$pendingFriendRequestCountHash() =>
    r'bc9bda552c8ef0d526e19ab77a604a71adf875fc';

/// Streams the number of pending incoming friend requests for the current user.
/// Backed by [FriendsRepository.getPendingReceivedRequests] — updates live.
///
/// Copied from [pendingFriendRequestCount].
@ProviderFor(pendingFriendRequestCount)
final pendingFriendRequestCountProvider =
    AutoDisposeStreamProvider<int>.internal(
      pendingFriendRequestCount,
      name: r'pendingFriendRequestCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingFriendRequestCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingFriendRequestCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
