// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: deprecated_member_use

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileHash() => r'placeholder_hash';

/// See also [profile].
@ProviderFor(profile)
const profileProvider = ProfileFamily();

class ProfileFamily extends Family<AsyncValue<Profile>> {
  const ProfileFamily();

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

class ProfileProvider extends AutoDisposeStreamProvider<Profile> {
  ProfileProvider(this.userId)
      : super(
          (ref) => profile(ref, userId),
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileHash,
        );

  final String userId;

  @override
  bool operator ==(Object other) {
    return other is ProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

typedef ProfileRef = AutoDisposeStreamProviderRef<Profile>;

String _$createProfileNotifierHash() => r'placeholder_hash';

/// See also [CreateProfileNotifier].
@ProviderFor(CreateProfileNotifier)
final createProfileNotifierProvider = AutoDisposeNotifierProvider<
    CreateProfileNotifier, ProfileFormState>.internal(
  CreateProfileNotifier.new,
  name: r'createProfileNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createProfileNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateProfileNotifier = AutoDisposeNotifier<ProfileFormState>;

String _$editProfileNotifierHash() => r'placeholder_hash';

/// See also [EditProfileNotifier].
@ProviderFor(EditProfileNotifier)
final editProfileNotifierProvider =
    AutoDisposeNotifierProvider<EditProfileNotifier, ProfileFormState>.internal(
  EditProfileNotifier.new,
  name: r'editProfileNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$editProfileNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EditProfileNotifier = AutoDisposeNotifier<ProfileFormState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
