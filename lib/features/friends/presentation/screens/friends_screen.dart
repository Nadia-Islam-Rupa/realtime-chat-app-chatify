import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/friends_providers.dart';

/// Friends tab body — three sub-tabs:
///   0. My Friends   – live list of accepted friends
///   1. Requests     – incoming pending requests (with badge count)
///   2. Find People  – all users shown on open, filterable, smart action button
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final colorScheme = Theme.of(context).colorScheme;

    // Global snackbars for action feedback
    ref.listen(friendActionsNotifierProvider, (prev, next) {
      if (!mounted) return;
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          behavior: SnackBarBehavior.floating,
        ));
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Column(
      children: [
        ColoredBox(
          color: colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: [
              const Tab(text: 'My Friends'),
              _RequestsTabLabel(userId: userId),
              const Tab(text: 'Find People'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _MyFriendsTab(userId: userId),
              _RequestsTab(userId: userId),
              _FindPeopleTab(currentUserId: userId),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Requests tab label — live badge
// ---------------------------------------------------------------------------

class _RequestsTabLabel extends ConsumerWidget {
  final String userId;
  const _RequestsTabLabel({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count =
        ref.watch(pendingRequestsProvider(userId)).valueOrNull?.length ?? 0;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Requests'),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Badge(label: Text('$count')),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 0 — My Friends
// ---------------------------------------------------------------------------

class _MyFriendsTab extends ConsumerWidget {
  final String userId;
  const _MyFriendsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsListProvider(userId));

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: e.toString()),
      data: (friends) {
        if (friends.isEmpty) {
          return const _EmptyState(
            icon: Icons.people_outline,
            title: 'No friends yet',
            subtitle: 'Use "Find People" to connect with others',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: friends.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 72),
          itemBuilder: (context, i) => _FriendTile(
            friendId: friends[i].friendId,
            currentUserId: userId,
            onRemove: () => _confirmRemove(context, ref, friends[i].friendId),
          ),
        );
      },
    );
  }

  Future<void> _confirmRemove(
      BuildContext context, WidgetRef ref, String friendId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove friend'),
        content: const Text('Remove this person from your friends list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(friendActionsNotifierProvider.notifier).removeFriend(friendId);
    }
  }
}

// ---------------------------------------------------------------------------
// Tab 1 — Requests
// ---------------------------------------------------------------------------

class _RequestsTab extends ConsumerWidget {
  final String userId;
  const _RequestsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRequestsProvider(userId));

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(message: e.toString()),
      data: (requests) {
        if (requests.isEmpty) {
          return const _EmptyState(
            icon: Icons.mark_email_unread_outlined,
            title: 'No pending requests',
            subtitle: 'When someone sends you a request it will appear here',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: requests.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 72),
          itemBuilder: (context, i) => _RequestTile(
            senderId: requests[i].senderId,
            requestId: requests[i].id,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 — Find People
// ---------------------------------------------------------------------------

class _FindPeopleTab extends ConsumerStatefulWidget {
  final String currentUserId;
  const _FindPeopleTab({required this.currentUserId});

  @override
  ConsumerState<_FindPeopleTab> createState() => _FindPeopleTabState();
}

class _FindPeopleTabState extends ConsumerState<_FindPeopleTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query =
        ref.watch(findPeopleNotifierProvider).query.toLowerCase();
    final allUsersAsync =
        ref.watch(allUsersProvider(widget.currentUserId));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Search / filter bar ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(findPeopleNotifierProvider.notifier)
                            .clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            onChanged: (v) {
              setState(() {}); // refresh clear button visibility
              ref.read(findPeopleNotifierProvider.notifier).setQuery(v);
            },
          ),
        ),

        // ── User list ────────────────────────────────────────────────────
        Expanded(
          child: allUsersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorView(message: e.toString()),
            data: (users) {
              // Filter by query client-side
              final filtered = query.isEmpty
                  ? users
                  : users
                      .where((u) =>
                          u.name.toLowerCase().contains(query) ||
                          (u.about?.toLowerCase().contains(query) ?? false))
                      .toList();

              if (filtered.isEmpty) {
                return _EmptyState(
                  icon: query.isEmpty
                      ? Icons.people_outline
                      : Icons.search_off,
                  title: query.isEmpty
                      ? 'No other users yet'
                      : 'No results for "$query"',
                  subtitle: query.isEmpty
                      ? 'Other users will appear here once they sign up'
                      : 'Try a different name',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, i) => _FindPeopleTile(
                  profile: filtered[i],
                  currentUserId: widget.currentUserId,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tiles
// ---------------------------------------------------------------------------

/// My Friends tab tile — loads profile, message shortcut, remove option.
class _FriendTile extends ConsumerWidget {
  final String friendId;
  final String currentUserId;
  final VoidCallback onRemove;

  const _FriendTile({
    required this.friendId,
    required this.currentUserId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(friendId));
    final isLoading =
        ref.watch(friendActionsNotifierProvider).isLoadingFor(friendId);

    return profileAsync.when(
      loading: () => const _LoadingTile(),
      error: (e, st) => _FallbackTile(id: friendId),
      data: (profile) => ListTile(
        leading: _Avatar(imageUrl: profile.imageUrl, name: profile.name),
        title: Text(profile.name,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: (profile.about?.isNotEmpty ?? false)
            ? Text(profile.about!,
                maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Direct message button ─────────────────────────
                  _MessageIconButton(otherUserId: profile.id),

                  // ── More options ──────────────────────────────────
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (v) {
                      if (v == 'view') {
                        context.push(RouteNames.profileViewPath(profile.id));
                      } else if (v == 'remove') {
                        onRemove();
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.person_outline),
                          title: Text('View profile'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'remove',
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.person_remove_outlined),
                          title: Text('Remove friend'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        onTap: () => context.push(RouteNames.profileViewPath(profile.id)),
      ),
    );
  }
}

/// Incoming request tile with Accept / Reject.
class _RequestTile extends ConsumerWidget {
  final String senderId;
  final String requestId;
  const _RequestTile({required this.senderId, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(senderId));
    final isLoading = ref
        .watch(friendActionsNotifierProvider)
        .isLoadingFor(requestId);

    return profileAsync.when(
      loading: () => const _LoadingTile(),
      error: (e, st) => _FallbackTile(id: senderId),
      data: (profile) => ListTile(
        leading: _Avatar(imageUrl: profile.imageUrl, name: profile.name),
        title: Text(profile.name,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: (profile.about?.isNotEmpty ?? false)
            ? Text(profile.about!,
                maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: AppColors.online,
                    tooltip: 'Accept',
                    onPressed: () => ref
                        .read(friendActionsNotifierProvider.notifier)
                        .acceptRequest(requestId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    color: Theme.of(context).colorScheme.error,
                    tooltip: 'Reject',
                    onPressed: () => ref
                        .read(friendActionsNotifierProvider.notifier)
                        .rejectRequest(requestId),
                  ),
                ],
              ),
        onTap: () => context.push(RouteNames.profileViewPath(profile.id)),
      ),
    );
  }
}

/// Find People tile — shows smart action button based on current relation.
class _FindPeopleTile extends ConsumerWidget {
  final Profile profile;
  final String currentUserId;
  const _FindPeopleTile(
      {required this.profile, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relation =
        ref.watch(userRelationProvider(currentUserId, profile.id));
    final actionState = ref.watch(friendActionsNotifierProvider);

    final loadingKey = relation.requestId ?? profile.id;
    final isLoading = actionState.isLoadingFor(loadingKey);

    return ListTile(
      leading: _Avatar(imageUrl: profile.imageUrl, name: profile.name),
      title: Text(profile.name,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: (profile.about?.isNotEmpty ?? false)
          ? Text(profile.about!,
              maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : relation.relation == UserRelation.friends
              // Already friends — show a direct message button
              ? _MessageIconButton(otherUserId: profile.id)
              : _RelationButton(
                  relation: relation,
                  profile: profile,
                ),
      onTap: () => context.push(RouteNames.profileViewPath(profile.id)),
    );
  }
}

/// The smart action button rendered based on [RelationInfo].
class _RelationButton extends ConsumerWidget {
  final RelationInfo relation;
  final Profile profile;
  const _RelationButton({required this.relation, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.read(friendActionsNotifierProvider.notifier);

    switch (relation.relation) {
      // ── Already friends ─────────────────────────────────────────────
      case UserRelation.friends:
        return OutlinedButton.icon(
          onPressed: null, // tap the tile to view profile; remove via My Friends
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Friends'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.online,
            side: BorderSide(color: AppColors.online.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );

      // ── I sent a request — show "Requested" + cancel option ─────────
      case UserRelation.requestSent:
        return OutlinedButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Cancel request?'),
                content: Text(
                    'Withdraw your friend request to ${profile.name}?'),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );

      // ── They sent me a request — show Accept + Reject ───────────────
      case UserRelation.requestReceived:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Accept
            FilledButton(
              onPressed: relation.requestId == null
                  ? null
                  : () => notifier.acceptRequest(relation.requestId!),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Accept'),
            ),
            const SizedBox(width: 6),
            // Reject
            OutlinedButton(
              onPressed: relation.requestId == null
                  ? null
                  : () => notifier.rejectRequest(relation.requestId!),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Reject'),
            ),
          ],
        );

      // ── No relation — show Add Friend ───────────────────────────────
      case UserRelation.none:
        return FilledButton.icon(
          onPressed: () => notifier.sendRequest(profile.id),
          icon: const Icon(Icons.person_add_outlined, size: 16),
          label: const Text('Add'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Message icon button — opens or creates a conversation with a friend
// ---------------------------------------------------------------------------

class _MessageIconButton extends ConsumerStatefulWidget {
  final String otherUserId;
  const _MessageIconButton({required this.otherUserId});

  @override
  ConsumerState<_MessageIconButton> createState() =>
      _MessageIconButtonState();
}

class _MessageIconButtonState extends ConsumerState<_MessageIconButton> {
  bool _loading = false;

  Future<void> _openChat() async {
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

// ---------------------------------------------------------------------------
// Shared micro-widgets
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  const _Avatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(imageUrl!));
    }
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return CircleAvatar(
      backgroundColor: AppColors.primaryLight,
      child: Text(initial,
          style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.bold)),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();
  @override
  Widget build(BuildContext context) => const ListTile(
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: Text('Loading…'),
      );
}

class _FallbackTile extends StatelessWidget {
  final String id;
  const _FallbackTile({required this.id});
  @override
  Widget build(BuildContext context) => ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(id),
      );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
