// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileHash() => r'65537aab2ba962a91f1cb7a9cd9e8baaeb92d653';

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

/// Exposes a live [Profile] for [userId] as an [AsyncValue].
/// Backed by Supabase realtime — online/last_seen update in real time.
///
/// Copied from [profile].
@ProviderFor(profile)
const profileProvider = ProfileFamily();

/// Exposes a live [Profile] for [userId] as an [AsyncValue].
/// Backed by Supabase realtime — online/last_seen update in real time.
///
/// Copied from [profile].
class ProfileFamily extends Family<AsyncValue<Profile>> {
  /// Exposes a live [Profile] for [userId] as an [AsyncValue].
  /// Backed by Supabase realtime — online/last_seen update in real time.
  ///
  /// Copied from [profile].
  const ProfileFamily();

  /// Exposes a live [Profile] for [userId] as an [AsyncValue].
  /// Backed by Supabase realtime — online/last_seen update in real time.
  ///
  /// Copied from [profile].
  ProfileProvider call(String userId) {
    return ProfileProvider(userId);
  }

  @override
  ProfileProvider getProviderOverride(covariant ProfileProvider provider) {
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
  String? get name => r'profileProvider';
}

/// Exposes a live [Profile] for [userId] as an [AsyncValue].
/// Backed by Supabase realtime — online/last_seen update in real time.
///
/// Copied from [profile].
class ProfileProvider extends AutoDisposeStreamProvider<Profile> {
  /// Exposes a live [Profile] for [userId] as an [AsyncValue].
  /// Backed by Supabase realtime — online/last_seen update in real time.
  ///
  /// Copied from [profile].
  ProfileProvider(String userId)
    : this._internal(
        (ref) => profile(ref as ProfileRef, userId),
        from: profileProvider,
        name: r'profileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileHash,
        dependencies: ProfileFamily._dependencies,
        allTransitiveDependencies: ProfileFamily._allTransitiveDependencies,
        userId: userId,
      );

  ProfileProvider._internal(
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
  Override overrideWith(Stream<Profile> Function(ProfileRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: ProfileProvider._internal(
        (ref) => create(ref as ProfileRef),
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
  AutoDisposeStreamProviderElement<Profile> createElement() {
    return _ProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileProvider && other.userId == userId;
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
mixin ProfileRef on AutoDisposeStreamProviderRef<Profile> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ProfileProviderElement extends AutoDisposeStreamProviderElement<Profile>
    with ProfileRef {
  _ProfileProviderElement(super.provider);

  @override
  String get userId => (origin as ProfileProvider).userId;
}

String _$createProfileNotifierHash() =>
    r'7cc2668187f08cd26696afdf53c7b9cd3b3b9bfa';

/// See also [CreateProfileNotifier].
@ProviderFor(CreateProfileNotifier)
final createProfileNotifierProvider =
    AutoDisposeNotifierProvider<
      CreateProfileNotifier,
      ProfileFormState
    >.internal(
      CreateProfileNotifier.new,
      name: r'createProfileNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createProfileNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CreateProfileNotifier = AutoDisposeNotifier<ProfileFormState>;
String _$editProfileNotifierHash() =>
    r'082cfac872ceeeb250057dcde59d96934d703566';

/// See also [EditProfileNotifier].
@ProviderFor(EditProfileNotifier)
final editProfileNotifierProvider =
    AutoDisposeNotifierProvider<EditProfileNotifier, ProfileFormState>.internal(
      EditProfileNotifier.new,
      name: r'editProfileNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$editProfileNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EditProfileNotifier = AutoDisposeNotifier<ProfileFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
