// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authStateHash() => r'c8a85e86b40cace486961bbb19f8bf33880490a1';

/// Emits [User?] whenever the Supabase session changes.
/// [null] means the user is signed out.
/// Consumed by the router's redirect logic and any widget that needs auth state.
///
/// Copied from [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<User?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<User?>;
String _$signInNotifierHash() => r'a39ae4e996ec324375f8eb80f0b3e2b0dadd9bb9';

/// Manages the async state for the sign-in action.
/// State is [AsyncValue<void>] — loading/error/success.
///
/// Copied from [SignInNotifier].
@ProviderFor(SignInNotifier)
final signInNotifierProvider =
    AutoDisposeNotifierProvider<SignInNotifier, AsyncValue<void>>.internal(
      SignInNotifier.new,
      name: r'signInNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signInNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignInNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$signUpNotifierHash() => r'f56850eb2e9de03bcd9f5308873f3b285179cac4';

/// Manages the async state for the sign-up action.
///
/// Copied from [SignUpNotifier].
@ProviderFor(SignUpNotifier)
final signUpNotifierProvider =
    AutoDisposeNotifierProvider<SignUpNotifier, AsyncValue<void>>.internal(
      SignUpNotifier.new,
      name: r'signUpNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signUpNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignUpNotifier = AutoDisposeNotifier<AsyncValue<void>>;
String _$signOutNotifierHash() => r'325aac0437d8f2f149d9536aeb9c9b4cd998bf6e';

/// Manages the async state for the sign-out action.
///
/// Copied from [SignOutNotifier].
@ProviderFor(SignOutNotifier)
final signOutNotifierProvider =
    AutoDisposeNotifierProvider<SignOutNotifier, AsyncValue<void>>.internal(
      SignOutNotifier.new,
      name: r'signOutNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$signOutNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SignOutNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
