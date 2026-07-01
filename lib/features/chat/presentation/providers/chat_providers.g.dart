// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationsHash() => r'f53536a0708e0d2b55dd3b7d124b97b73752ff06';

/// See also [conversations].
@ProviderFor(conversations)
final conversationsProvider =
    AutoDisposeStreamProvider<List<Conversation>>.internal(
      conversations,
      name: r'conversationsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConversationsRef = AutoDisposeStreamProviderRef<List<Conversation>>;
String _$messagesHash() => r'f5ae60a01650d34fd924ccfde3b23ea10bab2e94';

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

/// See also [messages].
@ProviderFor(messages)
const messagesProvider = MessagesFamily();

/// See also [messages].
class MessagesFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [messages].
  const MessagesFamily();

  /// See also [messages].
  MessagesProvider call(String conversationId) {
    return MessagesProvider(conversationId);
  }

  @override
  MessagesProvider getProviderOverride(covariant MessagesProvider provider) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesProvider';
}

/// See also [messages].
class MessagesProvider extends AutoDisposeStreamProvider<List<Message>> {
  /// See also [messages].
  MessagesProvider(String conversationId)
    : this._internal(
        (ref) => messages(ref as MessagesRef, conversationId),
        from: messagesProvider,
        name: r'messagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesHash,
        dependencies: MessagesFamily._dependencies,
        allTransitiveDependencies: MessagesFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  MessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    Stream<List<Message>> Function(MessagesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesProvider._internal(
        (ref) => create(ref as MessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Message>> createElement() {
    return _MessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesProvider && other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesRef on AutoDisposeStreamProviderRef<List<Message>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _MessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<Message>>
    with MessagesRef {
  _MessagesProviderElement(super.provider);

  @override
  String get conversationId => (origin as MessagesProvider).conversationId;
}

String _$typingStatusHash() => r'55b1d2076739f27e41b03614b7b07fd5f46f0bb6';

/// See also [typingStatus].
@ProviderFor(typingStatus)
const typingStatusProvider = TypingStatusFamily();

/// See also [typingStatus].
class TypingStatusFamily extends Family<AsyncValue<List<TypingStatus>>> {
  /// See also [typingStatus].
  const TypingStatusFamily();

  /// See also [typingStatus].
  TypingStatusProvider call(String conversationId) {
    return TypingStatusProvider(conversationId);
  }

  @override
  TypingStatusProvider getProviderOverride(
    covariant TypingStatusProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'typingStatusProvider';
}

/// See also [typingStatus].
class TypingStatusProvider
    extends AutoDisposeStreamProvider<List<TypingStatus>> {
  /// See also [typingStatus].
  TypingStatusProvider(String conversationId)
    : this._internal(
        (ref) => typingStatus(ref as TypingStatusRef, conversationId),
        from: typingStatusProvider,
        name: r'typingStatusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$typingStatusHash,
        dependencies: TypingStatusFamily._dependencies,
        allTransitiveDependencies:
            TypingStatusFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  TypingStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    Stream<List<TypingStatus>> Function(TypingStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TypingStatusProvider._internal(
        (ref) => create(ref as TypingStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TypingStatus>> createElement() {
    return _TypingStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TypingStatusProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TypingStatusRef on AutoDisposeStreamProviderRef<List<TypingStatus>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _TypingStatusProviderElement
    extends AutoDisposeStreamProviderElement<List<TypingStatus>>
    with TypingStatusRef {
  _TypingStatusProviderElement(super.provider);

  @override
  String get conversationId => (origin as TypingStatusProvider).conversationId;
}

String _$getOrCreateConversationHash() =>
    r'0ebaf1515da874409056d67135556345efdb498d';

/// See also [getOrCreateConversation].
@ProviderFor(getOrCreateConversation)
const getOrCreateConversationProvider = GetOrCreateConversationFamily();

/// See also [getOrCreateConversation].
class GetOrCreateConversationFamily extends Family<AsyncValue<Conversation>> {
  /// See also [getOrCreateConversation].
  const GetOrCreateConversationFamily();

  /// See also [getOrCreateConversation].
  GetOrCreateConversationProvider call(String otherUserId) {
    return GetOrCreateConversationProvider(otherUserId);
  }

  @override
  GetOrCreateConversationProvider getProviderOverride(
    covariant GetOrCreateConversationProvider provider,
  ) {
    return call(provider.otherUserId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getOrCreateConversationProvider';
}

/// See also [getOrCreateConversation].
class GetOrCreateConversationProvider
    extends AutoDisposeFutureProvider<Conversation> {
  /// See also [getOrCreateConversation].
  GetOrCreateConversationProvider(String otherUserId)
    : this._internal(
        (ref) => getOrCreateConversation(
          ref as GetOrCreateConversationRef,
          otherUserId,
        ),
        from: getOrCreateConversationProvider,
        name: r'getOrCreateConversationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getOrCreateConversationHash,
        dependencies: GetOrCreateConversationFamily._dependencies,
        allTransitiveDependencies:
            GetOrCreateConversationFamily._allTransitiveDependencies,
        otherUserId: otherUserId,
      );

  GetOrCreateConversationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.otherUserId,
  }) : super.internal();

  final String otherUserId;

  @override
  Override overrideWith(
    FutureOr<Conversation> Function(GetOrCreateConversationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetOrCreateConversationProvider._internal(
        (ref) => create(ref as GetOrCreateConversationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        otherUserId: otherUserId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Conversation> createElement() {
    return _GetOrCreateConversationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetOrCreateConversationProvider &&
        other.otherUserId == otherUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, otherUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetOrCreateConversationRef on AutoDisposeFutureProviderRef<Conversation> {
  /// The parameter `otherUserId` of this provider.
  String get otherUserId;
}

class _GetOrCreateConversationProviderElement
    extends AutoDisposeFutureProviderElement<Conversation>
    with GetOrCreateConversationRef {
  _GetOrCreateConversationProviderElement(super.provider);

  @override
  String get otherUserId =>
      (origin as GetOrCreateConversationProvider).otherUserId;
}

String _$typingDebounceNotifierHash() =>
    r'779b437498800bdaed7d23193a59594df06ac739';

abstract class _$TypingDebounceNotifier
    extends BuildlessAutoDisposeNotifier<bool> {
  late final String conversationId;

  bool build(String conversationId);
}

/// See also [TypingDebounceNotifier].
@ProviderFor(TypingDebounceNotifier)
const typingDebounceNotifierProvider = TypingDebounceNotifierFamily();

/// See also [TypingDebounceNotifier].
class TypingDebounceNotifierFamily extends Family<bool> {
  /// See also [TypingDebounceNotifier].
  const TypingDebounceNotifierFamily();

  /// See also [TypingDebounceNotifier].
  TypingDebounceNotifierProvider call(String conversationId) {
    return TypingDebounceNotifierProvider(conversationId);
  }

  @override
  TypingDebounceNotifierProvider getProviderOverride(
    covariant TypingDebounceNotifierProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'typingDebounceNotifierProvider';
}

/// See also [TypingDebounceNotifier].
class TypingDebounceNotifierProvider
    extends AutoDisposeNotifierProviderImpl<TypingDebounceNotifier, bool> {
  /// See also [TypingDebounceNotifier].
  TypingDebounceNotifierProvider(String conversationId)
    : this._internal(
        () => TypingDebounceNotifier()..conversationId = conversationId,
        from: typingDebounceNotifierProvider,
        name: r'typingDebounceNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$typingDebounceNotifierHash,
        dependencies: TypingDebounceNotifierFamily._dependencies,
        allTransitiveDependencies:
            TypingDebounceNotifierFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  TypingDebounceNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  bool runNotifierBuild(covariant TypingDebounceNotifier notifier) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(TypingDebounceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TypingDebounceNotifierProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TypingDebounceNotifier, bool>
  createElement() {
    return _TypingDebounceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TypingDebounceNotifierProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TypingDebounceNotifierRef on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _TypingDebounceNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TypingDebounceNotifier, bool>
    with TypingDebounceNotifierRef {
  _TypingDebounceNotifierProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as TypingDebounceNotifierProvider).conversationId;
}

String _$sendMessageNotifierHash() =>
    r'2913b881060b46e170c8df5e2d4c2914805a71fc';

abstract class _$SendMessageNotifier
    extends BuildlessAutoDisposeNotifier<SendMessageState> {
  late final String conversationId;

  SendMessageState build(String conversationId);
}

/// See also [SendMessageNotifier].
@ProviderFor(SendMessageNotifier)
const sendMessageNotifierProvider = SendMessageNotifierFamily();

/// See also [SendMessageNotifier].
class SendMessageNotifierFamily extends Family<SendMessageState> {
  /// See also [SendMessageNotifier].
  const SendMessageNotifierFamily();

  /// See also [SendMessageNotifier].
  SendMessageNotifierProvider call(String conversationId) {
    return SendMessageNotifierProvider(conversationId);
  }

  @override
  SendMessageNotifierProvider getProviderOverride(
    covariant SendMessageNotifierProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sendMessageNotifierProvider';
}

/// See also [SendMessageNotifier].
class SendMessageNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<SendMessageNotifier, SendMessageState> {
  /// See also [SendMessageNotifier].
  SendMessageNotifierProvider(String conversationId)
    : this._internal(
        () => SendMessageNotifier()..conversationId = conversationId,
        from: sendMessageNotifierProvider,
        name: r'sendMessageNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sendMessageNotifierHash,
        dependencies: SendMessageNotifierFamily._dependencies,
        allTransitiveDependencies:
            SendMessageNotifierFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  SendMessageNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  SendMessageState runNotifierBuild(covariant SendMessageNotifier notifier) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(SendMessageNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SendMessageNotifierProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SendMessageNotifier, SendMessageState>
  createElement() {
    return _SendMessageNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SendMessageNotifierProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SendMessageNotifierRef
    on AutoDisposeNotifierProviderRef<SendMessageState> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _SendMessageNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          SendMessageNotifier,
          SendMessageState
        >
    with SendMessageNotifierRef {
  _SendMessageNotifierProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as SendMessageNotifierProvider).conversationId;
}

String _$markAsReadNotifierHash() =>
    r'1ef3e78595849bf0482cab45e102f98f90f75870';

abstract class _$MarkAsReadNotifier extends BuildlessAutoDisposeNotifier<void> {
  late final String conversationId;

  void build(String conversationId);
}

/// See also [MarkAsReadNotifier].
@ProviderFor(MarkAsReadNotifier)
const markAsReadNotifierProvider = MarkAsReadNotifierFamily();

/// See also [MarkAsReadNotifier].
class MarkAsReadNotifierFamily extends Family<void> {
  /// See also [MarkAsReadNotifier].
  const MarkAsReadNotifierFamily();

  /// See also [MarkAsReadNotifier].
  MarkAsReadNotifierProvider call(String conversationId) {
    return MarkAsReadNotifierProvider(conversationId);
  }

  @override
  MarkAsReadNotifierProvider getProviderOverride(
    covariant MarkAsReadNotifierProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'markAsReadNotifierProvider';
}

/// See also [MarkAsReadNotifier].
class MarkAsReadNotifierProvider
    extends AutoDisposeNotifierProviderImpl<MarkAsReadNotifier, void> {
  /// See also [MarkAsReadNotifier].
  MarkAsReadNotifierProvider(String conversationId)
    : this._internal(
        () => MarkAsReadNotifier()..conversationId = conversationId,
        from: markAsReadNotifierProvider,
        name: r'markAsReadNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$markAsReadNotifierHash,
        dependencies: MarkAsReadNotifierFamily._dependencies,
        allTransitiveDependencies:
            MarkAsReadNotifierFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  MarkAsReadNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  void runNotifierBuild(covariant MarkAsReadNotifier notifier) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(MarkAsReadNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MarkAsReadNotifierProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<MarkAsReadNotifier, void> createElement() {
    return _MarkAsReadNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarkAsReadNotifierProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarkAsReadNotifierRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _MarkAsReadNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<MarkAsReadNotifier, void>
    with MarkAsReadNotifierRef {
  _MarkAsReadNotifierProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as MarkAsReadNotifierProvider).conversationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
