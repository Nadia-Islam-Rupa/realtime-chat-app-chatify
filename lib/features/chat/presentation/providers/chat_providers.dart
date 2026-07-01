import 'dart:async';

import 'package:flutter/widgets.dart';
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

/// Streams the current user's conversation list ordered by last_message_at DESC.
/// Each [Conversation] has the other participant's [Profile] populated.
@riverpod
Stream<List<Conversation>> conversations(ConversationsRef ref) async* {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    yield [];
    return;
  }

  yield* ref
      .watch(chatRepositoryProvider)
      .getConversationsList(user.id)
      .map((either) => either.fold(
            (f) => throw Exception(f.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 2. Messages stream (family by conversationId)
// ---------------------------------------------------------------------------

/// Streams all messages for a given [conversationId] ordered by created_at ASC.
@riverpod
Stream<List<Message>> messages(MessagesRef ref, String conversationId) {
  return ref
      .watch(chatRepositoryProvider)
      .getMessages(conversationId)
      .map((either) => either.fold(
            (f) => throw Exception(f.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 3. Typing status stream (family by conversationId)
// ---------------------------------------------------------------------------

/// Streams the typing-status rows for [conversationId].
@riverpod
Stream<List<TypingStatus>> typingStatus(
    TypingStatusRef ref, String conversationId) {
  return GetTypingStatusUseCase(ref.watch(chatRepositoryProvider))(
          conversationId)
      .map((either) => either.fold(
            (f) => throw Exception(f.message),
            (list) => list,
          ));
}

// ---------------------------------------------------------------------------
// 4. GetOrCreateConversation — async action
// ---------------------------------------------------------------------------

/// Returns the conversation ID for a given [otherUserId], creating one if
/// none exists.  The result is cached per [otherUserId].
@riverpod
Future<Conversation> getOrCreateConversation(
  GetOrCreateConversationRef ref,
  String otherUserId,
) async {
  final result = await GetOrCreateConversationUseCase(
    ref.watch(chatRepositoryProvider),
  )(otherUserId);
  return result.fold(
    (f) => throw Exception(f.message),
    (conv) => conv,
  );
}

// ---------------------------------------------------------------------------
// 5. Typing debounce notifier
// ---------------------------------------------------------------------------

/// Manages typing-indicator logic for a single conversation.
///
/// Call [onTextChanged] whenever the message TextField's [onChanged] fires.
/// The notifier will:
///   - Set is_typing = true immediately on first keystroke.
///   - Reset the debounce timer on every keystroke.
///   - Set is_typing = false after [_debounceDuration] of inactivity.
///   - Clear is_typing on [dispose] (screen closed).
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
      // First keystroke — immediately report typing = true
      state = true;
      _setTyping(user.id, isTyping: true);
    }

    // Reset debounce timer
    _timer?.cancel();
    _timer = Timer(_debounceDuration, () {
      if (_disposed) return;
      state = false;
      _setTyping(user.id, isTyping: false);
    });
  }

  void clearTyping() {
    if (_disposed) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    _timer?.cancel();
    if (state) {
      state = false;
      _setTyping(user.id, isTyping: false);
    }
    _disposed = true;
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
// 6. SendMessage notifier
// ---------------------------------------------------------------------------

class SendMessageState {
  final bool isSending;
  final String? error;
  const SendMessageState({this.isSending = false, this.error});
}

@riverpod
class SendMessageNotifier extends _$SendMessageNotifier {
  @override
  SendMessageState build(String conversationId) =>
      const SendMessageState();

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

      await client.storage
          .from(AppConstants.chatMediaBucket)
          .uploadBinary(
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
// 7. MarkMessagesAsRead notifier
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
