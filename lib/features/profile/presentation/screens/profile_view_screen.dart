import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../friends/presentation/providers/friends_providers.dart';
import '../providers/profile_providers.dart';

/// Displays another user's public profile.
class ProfileViewScreen extends ConsumerWidget {
  final String userId;
  const ProfileViewScreen({super.key, required this.userId});

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'a while ago';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(e.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
        data: (profile) => CustomScrollView(
          slivers: [
            // ── Collapsible app bar ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryDark,
                            colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 64,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: profile.imageUrl != null
                                ? NetworkImage(profile.imageUrl!)
                                : null,
                            child: profile.imageUrl == null
                                ? const Icon(Icons.person,
                                    size: 64, color: AppColors.primary)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: profile.isOnline
                                      ? AppColors.online
                                      : colorScheme.outline,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                profile.isOnline
                                    ? 'Online'
                                    : 'Last seen ${_formatLastSeen(profile.lastSeen)}',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info + actions ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (profile.about?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 6),
                      Text(
                        profile.about!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    if (profile.bio?.isNotEmpty ?? false) ...[
                      Text('About',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(profile.bio!,
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 24),
                    ],

                    // ── Buttons ──────────────────────────────────────
                    _ProfileActions(otherUserId: userId),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile action buttons (Message + Friend action)
// ---------------------------------------------------------------------------

class _ProfileActions extends ConsumerWidget {
  final String otherUserId;
  const _ProfileActions({required this.otherUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final currentUserId = currentUser?.id;

    // Derive the current relation so we show the right friend button
    final relation = currentUserId != null
        ? ref.watch(userRelationProvider(currentUserId, otherUserId))
        : const RelationInfo(relation: UserRelation.none);

    final actionState = ref.watch(friendActionsNotifierProvider);
    final loadingKey = relation.requestId ?? otherUserId;
    final isLoading = actionState.isLoadingFor(loadingKey);

    return Row(
      children: [
        // ── Message ──────────────────────────────────────────────────
        Expanded(
          child: _MessageButton(otherUserId: otherUserId),
        ),
        const SizedBox(width: 12),

        // ── Friend action ─────────────────────────────────────────────
        Expanded(
          child: isLoading
              ? OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _FriendActionButton(
                  relation: relation,
                  otherUserId: otherUserId,
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Message button — calls getOrCreateConversation then pushes to ChatScreen
// ---------------------------------------------------------------------------

class _MessageButton extends ConsumerStatefulWidget {
  final String otherUserId;
  const _MessageButton({required this.otherUserId});

  @override
  ConsumerState<_MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends ConsumerState<_MessageButton> {
  bool _loading = false;

  Future<void> _openChat(BuildContext context) async {
    setState(() => _loading = true);
    try {
      final conv = await ref.read(
        getOrCreateConversationProvider(widget.otherUserId).future,
      );
      if (!context.mounted) return;
      context.push(
        RouteNames.chatPath(conv.id),
        extra: widget.otherUserId,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open chat: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _loading ? null : () => _openChat(context),
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.chat_bubble_outline),
      label: const Text('Message'),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Friend action button — smart based on current relation
// ---------------------------------------------------------------------------

class _FriendActionButton extends ConsumerWidget {
  final RelationInfo relation;
  final String otherUserId;
  const _FriendActionButton(
      {required this.relation, required this.otherUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.read(friendActionsNotifierProvider.notifier);

    switch (relation.relation) {
      case UserRelation.friends:
        return OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Friends'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.online,
            side: BorderSide(color: AppColors.online.withValues(alpha: 0.5)),
            minimumSize: const Size.fromHeight(48),
          ),
        );

      case UserRelation.requestSent:
        return OutlinedButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Cancel request?'),
                content:
                    const Text('Withdraw your friend request?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('No')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Cancel request')),
                ],
              ),
            );
            if (confirmed == true && relation.requestId != null) {
              notifier.cancelRequest(relation.requestId!);
            }
          },
          icon: const Icon(Icons.hourglass_top_outlined, size: 16),
          label: const Text('Requested'),
          style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48)),
        );

      case UserRelation.requestReceived:
        return FilledButton.icon(
          onPressed: relation.requestId == null
              ? null
              : () => notifier.acceptRequest(relation.requestId!),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Accept'),
          style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48)),
        );

      case UserRelation.none:
        return FilledButton.icon(
          onPressed: () => notifier.sendRequest(otherUserId),
          icon: const Icon(Icons.person_add_outlined, size: 16),
          label: const Text('Add Friend'),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            minimumSize: const Size.fromHeight(48),
          ),
        );
    }
  }
}
