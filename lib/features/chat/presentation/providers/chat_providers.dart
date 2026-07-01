import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/typing_status.dart';
import '../../domain/usecases/get_or_create_conversation_use_case.dart';
import '../../domain/usecases/get_typing_status_use_case.dart';
import '../../domain/usecases/mark_messages_as_read_use_case.dart';
import '../../domain/usecases/send_message_use_case.dart';
import '../../domain/usecases/set_typing_status_use_case.dart';

part 'chat_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Conversations list stream
// ---------------------------------------------------------------------------
//
// IMPORTANT: do NOT use async* / yield* here.
// yield* would create a second subscription on top of the repository's
// single-subscriber StreamController, which deadlocks — the inner controller
// never calls onListen because it already has a subscriber from the first
// yield*, so it never fires the initial fetch.
//
// Instead, we return the stream directly.  Riverpod's StreamProvider keeps
// exactly one active listener, matching the single-subscriber contract.

@riverpod
Stream<List<Conversation>> conversations(ConversationsRef ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    // Not logged in — return a stream that immediately emits an empty list
    return Stream.value([]);
  }

  return ref
      .watch(chatRepositoryProvider)
      .getConversationsList(user.id)
      .map((either) => either.fold(
            (failure) => throw Exception(failure.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 2. Messages stream (keyed by conversationId)
// ---------------------------------------------------------------------------

@riverpod
Stream<List<Message>> messages(MessagesRef ref, String conversationId) {
  return ref
      .watch(chatRepositoryProvider)
      .getMessages(conversationId)
      .map((either) => either.fold(
            (failure) => throw Exception(failure.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 3. Typing status stream (keyed by conversationId)
// ---------------------------------------------------------------------------

@riverpod
Stream<List<TypingStatus>> typingStatus(
    TypingStatusRef ref, String conversationId) {
  return GetTypingStatusUseCase(ref.watch(chatRepositoryProvider))(
          conversationId)
      .map((either) => either.fold(
            (failure) => throw Exception(failure.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 4. GetOrCreateConversation (cached async future per otherUserId)
// ---------------------------------------------------------------------------

@riverpod
Future<Conversation> getOrCreateConversation(
  GetOrCreateConversationRef ref,
  String otherUserId,
) async {
  final result = await GetOrCreateConversationUseCase(
    ref.watch(chatRepositoryProvider),
  )(otherUserId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (conv) => conv,
  );
}

// ---------------------------------------------------------------------------
// 5. Typing debounce notifier (keyed by conversationId)
// ---------------------------------------------------------------------------

@riverpod
class TypingDebounceNotifier extends _$TypingDebounceNotifier {
  static const _debounceDuration = Duration(seconds: 3);

  Timer? _timer;
  bool _disposed = false;

  @override
  bool build(String conversationId) => false;

  void onTextChanged(String text) {
    if (_disposed) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    if (!state) {
      state = true;
      _setTyping(user.id, isTyping: true);
    }

    _timer?.cancel();
    _timer = Timer(_debounceDuration, () {
      if (_disposed) return;
      state = false;
      _setTyping(user.id, isTyping: false);
    });
  }

  /// Call when the screen closes or the user hits send.
  void clearTyping() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null && state) {
      state = false;
      _setTyping(user.id, isTyping: false);
    }
  }

  Future<void> _setTyping(String userId, {required bool isTyping}) async {
    if (_disposed) return;
    await SetTypingStatusUseCase(ref.read(chatRepositoryProvider))(
      conversationId,
      userId,
      isTyping: isTyping,
    );
  }
}

// ---------------------------------------------------------------------------
// 6. SendMessage notifier (keyed by conversationId)
// ---------------------------------------------------------------------------

class SendMessageState {
  final bool isSending;
  final String? error;
  const SendMessageState({this.isSending = false, this.error});
}

@riverpod
class SendMessageNotifier extends _$SendMessageNotifier {
  @override
  SendMessageState build(String conversationId) => const SendMessageState();

  Future<void> sendText(String content) async {
    if (content.trim().isEmpty) return;
    state = const SendMessageState(isSending: true);

    final result = await SendMessageUseCase(ref.read(chatRepositoryProvider))(
      conversationId,
      content.trim(),
    );

    state = result.fold(
      (f) => SendMessageState(error: f.message),
      (_) => const SendMessageState(),
    );
  }

  Future<void> sendImage(XFile file) async {
    state = const SendMessageState(isSending: true);
    try {
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        state = const SendMessageState(error: 'Not authenticated');
        return;
      }

      final fileName =
          '${conversationId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';
      final bytes = await file.readAsBytes();

      await client.storage.from(AppConstants.chatMediaBucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      final publicUrl = client.storage
          .from(AppConstants.chatMediaBucket)
          .getPublicUrl(path);

      final result = await SendMessageUseCase(ref.read(chatRepositoryProvider))(
        conversationId,
        '',
        mediaUrl: publicUrl,
        mediaType: 'image',
      );

      state = result.fold(
        (f) => SendMessageState(error: f.message),
        (_) => const SendMessageState(),
      );
    } catch (e) {
      state = SendMessageState(error: e.toString());
    }
  }
}

// ---------------------------------------------------------------------------
// 7. MarkAsRead notifier (keyed by conversationId)
// ---------------------------------------------------------------------------

@riverpod
class MarkAsReadNotifier extends _$MarkAsReadNotifier {
  @override
  void build(String conversationId) {}

  Future<void> markRead() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    await MarkMessagesAsReadUseCase(ref.read(chatRepositoryProvider))(
      conversationId,
      user.id,
    );
  }
}
