// ignore_for_file: use_build_context_synchronously

import 'package:chatify/core/router/route_names.dart';
import 'package:chatify/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MessageIconButton extends ConsumerStatefulWidget {
  final String otherUserId;
  const MessageIconButton({super.key, required this.otherUserId});

  @override
  ConsumerState<MessageIconButton> createState() => _MessageIconButtonState();
}

class _MessageIconButtonState extends ConsumerState<MessageIconButton> {
  bool _loading = false;

  Future<void> _openChat() async {
    setState(() => _loading = true);
    try {
      final conv = await ref.read(
        getOrCreateConversationProvider(widget.otherUserId).future,
      );
      if (!context.mounted) return;

      context.push(RouteNames.chatPath(conv.id), extra: widget.otherUserId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open chat: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            tooltip: 'Message',
            color: Theme.of(context).colorScheme.primary,
            onPressed: _openChat,
          );
  }
}
