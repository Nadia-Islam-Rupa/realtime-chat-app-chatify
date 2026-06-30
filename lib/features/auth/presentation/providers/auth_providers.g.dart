// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: deprecated_member_use

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'placeholder_hash';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;

String _$signInNotifierHash() => r'placeholder_hash';

/// See also [SignInNotifier].
@ProviderFor(SignInNotifier)
final signInNotifierProvider =
    AutoDisposeNotifierProvider<SignInNotifier, AsyncValue<void>>.internal(
  SignInNotifier.new,
  name: r'signInNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signInNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignInNotifier = AutoDisposeNotifier<AsyncValue<void>>;

String _$signUpNotifierHash() => r'placeholder_hash';

/// See also [SignUpNotifier].
@ProviderFor(SignUpNotifier)
final signUpNotifierProvider =
    AutoDisposeNotifierProvider<SignUpNotifier, AsyncValue<void>>.internal(
  SignUpNotifier.new,
  name: r'signUpNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signUpNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignUpNotifier = AutoDisposeNotifier<AsyncValue<void>>;

String _$signOutNotifierHash() => r'placeholder_hash';

/// See also [SignOutNotifier].
@ProviderFor(SignOutNotifier)
final signOutNotifierProvider =
    AutoDisposeNotifierProvider<SignOutNotifier, AsyncValue<void>>.internal(
  SignOutNotifier.new,
  name: r'signOutNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signOutNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SignOutNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
