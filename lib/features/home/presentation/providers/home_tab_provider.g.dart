// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_tab_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeTabNotifierHash() => r'3cae0eab460d716154964f6b7540017072fa96fb';

/// Holds the currently selected [HomeTab].
///
/// Using a Riverpod notifier (not local widget State) means any part of the
/// app — e.g. a deep-link handler, a notification tap — can switch tabs
/// programmatically without holding a [BuildContext].
///
/// Usage:
///   Read:   ref.watch(homeTabNotifierProvider)
///   Write:  ref.read(homeTabNotifierProvider.notifier).setTab(HomeTab.friends)
///
/// Copied from [HomeTabNotifier].
@ProviderFor(HomeTabNotifier)
final homeTabNotifierProvider =
    NotifierProvider<HomeTabNotifier, HomeTab>.internal(
      HomeTabNotifier.new,
      name: r'homeTabNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeTabNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeTabNotifier = Notifier<HomeTab>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
