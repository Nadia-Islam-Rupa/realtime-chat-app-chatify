import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/friends_providers.dart';

/// Friends tab body — three sub-tabs:
///   0. My Friends  — live list of accepted friends
///   1. Requests    — incoming pending requests (with badge)
///   2. Find People — search all users and send requests
///
/// Mounted inside the HomeShellScreen IndexedStack for tab 1.
/// No Scaffold or AppBar — provided by HomeShellScreen.
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

    // Global action feedback
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
        // ── Sub-tab bar ──────────────────────────────────────────────────
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
        // ── Sub-tab bodies ───────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _MyFriendsTab(userId: userId),
              _RequestsTab(userId: userId),
              const _FindPeopleTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Requests tab label with live badge
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
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, i) => _FriendTile(
            friendId: friends[i].friendId,
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
            subtitle: 'When someone sends you a request it appears here',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
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
  const _FindPeopleTab();

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
    final searchState = ref.watch(searchUsersNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Search bar ───────────────────────────────────────────────────
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
                            .read(searchUsersNotifierProvider.notifier)
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
              setState(() {}); // refresh clear button
              ref.read(searchUsersNotifierProvider.notifier).search(v);
            },
          ),
        ),

        // ── Results area ─────────────────────────────────────────────────
        Expanded(
          child: _buildResults(searchState),
        ),
      ],
    );
  }

  Widget _buildResults(SearchState state) {
    if (state.query.isEmpty) {
      return const _EmptyState(
        icon: Icons.person_search_outlined,
        title: 'Find your friends',
        subtitle: 'Search people by their display name',
      );
    }
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _ErrorView(message: state.error!);
    }
    if (state.results.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off,
        title: 'No users found',
        subtitle: 'Try a different name',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.results.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, i) =>
          _SearchResultTile(profile: state.results[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// List tiles
// ---------------------------------------------------------------------------

/// A friend tile that loads the friend's profile via the existing stream.
class _FriendTile extends ConsumerWidget {
  final String friendId;
  final VoidCallback onRemove;

  const _FriendTile({required this.friendId, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(friendId));

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
        trailing: PopupMenuButton<String>(
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
        onTap: () => context.push(RouteNames.profileViewPath(profile.id)),
      ),
    );
  }
}

/// Incoming request tile — shows sender's profile with Accept / Reject buttons.
class _RequestTile extends ConsumerWidget {
  final String senderId;
  final String requestId;

  const _RequestTile({required this.senderId, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(senderId));
    final isLoading = ref.watch(friendActionsNotifierProvider).isLoading;

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
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Accept
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: AppColors.online,
                    tooltip: 'Accept',
                    onPressed: () => ref
                        .read(friendActionsNotifierProvider.notifier)
                        .acceptRequest(requestId),
                  ),
                  // Reject
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

/// Search result tile — shows profile with an Add button.
class _SearchResultTile extends ConsumerWidget {
  final Profile profile;
  const _SearchResultTile({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(friendActionsNotifierProvider).isLoading;

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
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FilledButton.icon(
              onPressed: () => ref
                  .read(friendActionsNotifierProvider.notifier)
                  .sendRequest(profile.id),
              icon: const Icon(Icons.person_add_outlined, size: 16),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
      onTap: () => context.push(RouteNames.profileViewPath(profile.id)),
    );
  }
}

// ---------------------------------------------------------------------------
// Micro widgets
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
