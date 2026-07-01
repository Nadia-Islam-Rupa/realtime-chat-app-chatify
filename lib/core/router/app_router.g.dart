// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileExistsHash() => r'c0802978b1c016451c521925c4ee38b2643b36c2';

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

/// Returns [true] if the given [userId] already has a profile row.
/// Used by the router redirect to decide whether to send a new user to
/// /create-profile or directly into the app.
///
/// Copied from [profileExists].
@ProviderFor(profileExists)
const profileExistsProvider = ProfileExistsFamily();

/// Returns [true] if the given [userId] already has a profile row.
/// Used by the router redirect to decide whether to send a new user to
/// /create-profile or directly into the app.
///
/// Copied from [profileExists].
class ProfileExistsFamily extends Family<AsyncValue<bool>> {
  /// Returns [true] if the given [userId] already has a profile row.
  /// Used by the router redirect to decide whether to send a new user to
  /// /create-profile or directly into the app.
  ///
  /// Copied from [profileExists].
  const ProfileExistsFamily();

  /// Returns [true] if the given [userId] already has a profile row.
  /// Used by the router redirect to decide whether to send a new user to
  /// /create-profile or directly into the app.
  ///
  /// Copied from [profileExists].
  ProfileExistsProvider call(String userId) {
    return ProfileExistsProvider(userId);
  }

  @override
  ProfileExistsProvider getProviderOverride(
    covariant ProfileExistsProvider provider,
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
  String? get name => r'profileExistsProvider';
}

/// Returns [true] if the given [userId] already has a profile row.
/// Used by the router redirect to decide whether to send a new user to
/// /create-profile or directly into the app.
///
/// Copied from [profileExists].
class ProfileExistsProvider extends AutoDisposeFutureProvider<bool> {
  /// Returns [true] if the given [userId] already has a profile row.
  /// Used by the router redirect to decide whether to send a new user to
  /// /create-profile or directly into the app.
  ///
  /// Copied from [profileExists].
  ProfileExistsProvider(String userId)
    : this._internal(
        (ref) => profileExists(ref as ProfileExistsRef, userId),
        from: profileExistsProvider,
        name: r'profileExistsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileExistsHash,
        dependencies: ProfileExistsFamily._dependencies,
        allTransitiveDependencies:
            ProfileExistsFamily._allTransitiveDependencies,
        userId: userId,
      );

  ProfileExistsProvider._internal(
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
    FutureOr<bool> Function(ProfileExistsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileExistsProvider._internal(
        (ref) => create(ref as ProfileExistsRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _ProfileExistsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileExistsProvider && other.userId == userId;
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
mixin ProfileExistsRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ProfileExistsProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with ProfileExistsRef {
  _ProfileExistsProviderElement(super.provider);

  @override
  String get userId => (origin as ProfileExistsProvider).userId;
}

String _$appRouterHash() => r'a8b6b43581d407ef3313c0054f9c4d49d7f1d4cc';

/// See also [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = AutoDisposeProvider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppRouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
