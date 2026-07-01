import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/conversation.dart';
import '../providers/chat_providers.dart';

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return conversationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
      ),
      data: (conversations) {
        if (conversations.isEmpty) {
          return const _EmptyConversations();
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(conversationsProvider),
          child: ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              return _ConversationTile(conversation: conversations[index]);
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Individual conversation tile
// ---------------------------------------------------------------------------

class _ConversationTile extends ConsumerWidget {
  final Conversation conversation;
  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final other = conversation.otherParticipant;
    final hasUnread = conversation.unreadCount > 0;
    final lastMsgAt = conversation.lastMessageAt;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: _Avatar(
        imageUrl: other?.imageUrl,
        name: other?.name ?? '?',
        isOnline: other?.isOnline ?? false,
      ),
      title: Text(
        other?.name ?? 'Unknown',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          // If the last message was sent by the current user, show a checkmark
          if (conversation.lastMessageBy == user?.id)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.done_all, size: 14, color: colorScheme.primary),
            ),
          Expanded(
            child: Text(
              conversation.lastMessage ?? 'No messages yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasUnread
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withAlpha(153),
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            lastMsgAt != null ? _formatTime(lastMsgAt) : '',
            style: theme.textTheme.labelSmall?.copyWith(
              color: hasUnread
                  ? colorScheme.primary
                  : colorScheme.onSurface.withAlpha(128),
              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                conversation.unreadCount > 99
                    ? '99+'
                    : '${conversation.unreadCount}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(height: 18),
        ],
      ),
      onTap: () {
        final otherId = user != null
            ? conversation.otherUserId(user.id)
            : conversation.participantTwo;
        context.push(RouteNames.chatPath(conversation.id), extra: otherId);
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);

    if (msgDay == today) {
      return DateFormat.jm().format(dt);
    } else if (today.difference(msgDay).inDays == 1) {
      return 'Yesterday';
    } else if (today.difference(msgDay).inDays < 7) {
      return DateFormat.E().format(dt); // Mon, Tue …
    }
    return DateFormat.MMMd().format(dt); // Jan 5
  }
}

// ---------------------------------------------------------------------------
// Avatar with online indicator
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool isOnline;

  const _Avatar({
    required this.imageUrl,
    required this.name,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
        if (isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyConversations extends StatelessWidget {
  const _EmptyConversations();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: colorScheme.primary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withAlpha(180),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find friends and start chatting!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}
