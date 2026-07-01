// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$callHistoryHash() => r'05e164d294396792799634f116b4a2c23c6c8f62';

/// See also [callHistory].
@ProviderFor(callHistory)
final callHistoryProvider = AutoDisposeStreamProvider<List<Call>>.internal(
  callHistory,
  name: r'callHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$callHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CallHistoryRef = AutoDisposeStreamProviderRef<List<Call>>;
String _$incomingCallHash() => r'c0123c21e6d327be1ce2ce2ced9cd98f9aa78eaf';

/// See also [incomingCall].
@ProviderFor(incomingCall)
final incomingCallProvider = AutoDisposeStreamProvider<Call?>.internal(
  incomingCall,
  name: r'incomingCallProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$incomingCallHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IncomingCallRef = AutoDisposeStreamProviderRef<Call?>;
String _$webRtcSessionNotifierHash() =>
    r'1a17f9f24f322dab29529de88c860da3435797e4';

/// See also [WebRtcSessionNotifier].
@ProviderFor(WebRtcSessionNotifier)
final webRtcSessionNotifierProvider =
    AutoDisposeNotifierProvider<
      WebRtcSessionNotifier,
      WebRtcSessionData
    >.internal(
      WebRtcSessionNotifier.new,
      name: r'webRtcSessionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$webRtcSessionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WebRtcSessionNotifier = AutoDisposeNotifier<WebRtcSessionData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
