// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: deprecated_member_use

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileExistsHash() => r'profile_exists_placeholder_hash';

/// See also [profileExists].
@ProviderFor(profileExists)
const profileExistsProvider = ProfileExistsFamily();

class ProfileExistsFamily extends Family<AsyncValue<bool>> {
  const ProfileExistsFamily();

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

class ProfileExistsProvider extends AutoDisposeFutureProvider<bool> {
  ProfileExistsProvider(this.userId)
      : super(
          (ref) => profileExists(ref, userId),
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileExistsHash,
        );

  final String userId;

  @override
  bool operator ==(Object other) {
    return other is ProfileExistsProvider && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

typedef ProfileExistsRef = AutoDisposeFutureProviderRef<bool>;

String _$appRouterHash() => r'app_router_placeholder_hash';

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

typedef AppRouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
