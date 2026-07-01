import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_providers.dart';

/// Full chat screen.
///
/// [conversationId] — UUID of the conversation row.
/// [otherUserId]    — The other participant's auth UID (used for the AppBar
///                    profile and to filter typing-status events).
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(markAsReadNotifierProvider(widget.conversationId).notifier)
          .markRead();
    });
  }

  @override
  void dispose() {
    ref
        .read(typingDebounceNotifierProvider(widget.conversationId).notifier)
        .clearTyping();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(maxExtent);
    }
  }

  Future<void> _pickAndSendImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
    );
    if (file == null) return;
    await ref
        .read(sendMessageNotifierProvider(widget.conversationId).notifier)
        .sendImage(file);
  }

  Future<void> _sendText() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    ref
        .read(typingDebounceNotifierProvider(widget.conversationId).notifier)
        .clearTyping();
    await ref
        .read(sendMessageNotifierProvider(widget.conversationId).notifier)
        .sendText(text);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;

    // profileProvider streams Profile (non-nullable) — AsyncValue<Profile>
    final otherProfileAsync = ref.watch(profileProvider(widget.otherUserId));

    // Auto-scroll + mark-read on new messages
    ref.listen(messagesProvider(widget.conversationId), (previous, next) {
      if (next.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
          ref
              .read(markAsReadNotifierProvider(widget.conversationId).notifier)
              .markRead();
        });
      }
    });

    return Scaffold(
      appBar: _buildAppBar(context, otherProfileAsync),
      body: Column(
        children: [
          Expanded(
            child: _MessagesList(
              conversationId: widget.conversationId,
              currentUserId: currentUser?.id ?? '',
              scrollController: _scrollController,
            ),
          ),
          _TypingIndicator(
            conversationId: widget.conversationId,
            otherUserId: widget.otherUserId,
          ),
          _InputBar(
            controller: _textController,
            focusNode: _focusNode,
            conversationId: widget.conversationId,
            onSend: _sendText,
            onPickImage: _pickAndSendImage,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    // profileProvider gives AsyncValue<Profile> — Profile is non-nullable
    AsyncValue<Profile> otherProfileAsync,
  ) {
    return AppBar(
      titleSpacing: 0,
      leading: BackButton(
        onPressed: () {
          ref
              .read(typingDebounceNotifierProvider(widget.conversationId)
                  .notifier)
              .clearTyping();
          Navigator.of(context).pop();
        },
      ),
      title: otherProfileAsync.when(
        loading: () => const _AppBarSkeleton(),
        // profile() stream can only error, not return null
        error: (err, st) => const Text('Chat'),
        data: (profile) => _AppBarProfile(
          profile: profile,
          onStatusText: _statusText,
        ),
      ),
    );
  }

  String _statusText(bool isOnline, DateTime? lastSeen) {
    if (isOnline) return 'Online';
    if (lastSeen != null) {
      final diff = DateTime.now().difference(lastSeen);
      if (diff.inMinutes < 1) return 'Last seen just now';
      if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes}m ago';
      if (diff.inHours < 24) return 'Last seen ${diff.inHours}h ago';
      return 'Last seen ${DateFormat.MMMd().format(lastSeen)}';
    }
    return 'Offline';
  }
}

// ---------------------------------------------------------------------------
// AppBar sub-widgets
// ---------------------------------------------------------------------------

class _AppBarSkeleton extends StatelessWidget {
  const _AppBarSkeleton();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        const SizedBox(width: 10),
        Container(
          width: 100,
          height: 14,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ],
    );
  }
}

class _AppBarProfile extends StatelessWidget {
  final Profile profile;
  final String Function(bool isOnline, DateTime? lastSeen) onStatusText;

  const _AppBarProfile({required this.profile, required this.onStatusText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: profile.imageUrl != null
                  ? NetworkImage(profile.imageUrl!)
                  : null,
              child: profile.imageUrl == null
                  ? Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (profile.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.online,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                onStatusText(profile.isOnline, profile.lastSeen),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: profile.isOnline
                          ? AppColors.online
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(140),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Messages list
// ---------------------------------------------------------------------------

class _MessagesList extends ConsumerWidget {
  final String conversationId;
  final String currentUserId;
  final ScrollController scrollController;

  const _MessagesList({
    required this.conversationId,
    required this.currentUserId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(conversationId));

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Text(
          'Error loading messages:\n$e',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Text(
              'Say hello! 👋',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(120),
                  ),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMine = message.senderId == currentUserId;
            final showDateSep = index == 0 ||
                !_isSameDay(
                    messages[index - 1].createdAt, message.createdAt);

            return Column(
              children: [
                if (showDateSep) _DateSeparator(date: message.createdAt),
                _MessageBubble(message: message, isMine: isMine),
              ],
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ---------------------------------------------------------------------------
// Date separator
// ---------------------------------------------------------------------------

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String label;
    if (_isSameDay(date, now)) {
      label = 'Today';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Yesterday';
    } else {
      label = DateFormat.yMMMd().format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(140),
                  ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ---------------------------------------------------------------------------
// Message bubble
// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bubbleColor = isMine
        ? (isDark ? AppColors.bubbleOutgoingDark : AppColors.bubbleOutgoing)
        : (isDark ? AppColors.bubbleIncomingDark : AppColors.bubbleIncoming);

    final textColor = theme.colorScheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: message.hasMedia
              ? const EdgeInsets.all(4)
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image media ────────────────────────────────────────────
              if (message.hasMedia && message.mediaType == MediaType.image) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    message.mediaUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 200,
                      height: 150,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        width: 200,
                        height: 150,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                if (message.content != null && message.content!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 6, left: 10, right: 10, bottom: 2),
                    child: Text(
                      message.content!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: textColor),
                    ),
                  ),
              ],

              // ── Text content ───────────────────────────────────────────
              if (!message.hasMedia &&
                  message.content != null &&
                  message.content!.isNotEmpty)
                Text(
                  message.content!,
                  style:
                      theme.textTheme.bodyMedium?.copyWith(color: textColor),
                ),

              // ── Timestamp + read tick ──────────────────────────────────
              Padding(
                padding: message.hasMedia
                    ? const EdgeInsets.only(right: 8, bottom: 4)
                    : EdgeInsets.zero,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat.jm().format(message.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor.withAlpha(140),
                        fontSize: 10,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 3),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 13,
                        color: message.isRead
                            ? theme.colorScheme.primary
                            : textColor.withAlpha(140),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typing indicator
// ---------------------------------------------------------------------------

class _TypingIndicator extends ConsumerWidget {
  final String conversationId;
  final String otherUserId;

  const _TypingIndicator({
    required this.conversationId,
    required this.otherUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typingAsync = ref.watch(typingStatusProvider(conversationId));

    final isOtherTyping = typingAsync.valueOrNull
            ?.any((ts) => ts.userId == otherUserId && ts.isTyping) ??
        false;

    if (!isOtherTyping) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          const _TypingDots(),
          const SizedBox(width: 8),
          Text(
            'typing…',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(160),
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 28,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final phase =
                  ((_controller.value * 3) - i).clamp(0.0, 1.0);
              final scale =
                  0.5 + (phase < 0.5 ? phase : 1 - phase) * 1.0;
              return Transform.scale(
                scale: scale,
                child: CircleAvatar(
                  radius: 3.5,
                  backgroundColor: color,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input bar
// ---------------------------------------------------------------------------

class _InputBar extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String conversationId;
  final VoidCallback onSend;
  final VoidCallback onPickImage;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.conversationId,
    required this.onSend,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendState = ref.watch(sendMessageNotifierProvider(conversationId));
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Image attach button
            IconButton(
              onPressed: sendState.isSending ? null : onPickImage,
              icon: const Icon(Icons.attach_file_rounded),
              tooltip: 'Attach image',
              color: theme.colorScheme.primary,
            ),

            // Text field
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (text) {
                  ref
                      .read(typingDebounceNotifierProvider(conversationId)
                          .notifier)
                      .onTextChanged(text);
                },
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(120),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withAlpha(120),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Send button — rebuilds only when controller text changes
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final hasText = controller.text.trim().isNotEmpty;
                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasText
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withAlpha(80),
                    shape: BoxShape.circle,
                  ),
                  child: sendState.isSending
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send_rounded, size: 20),
                          color: theme.colorScheme.onPrimary,
                          onPressed: hasText ? onSend : null,
                          padding: EdgeInsets.zero,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
