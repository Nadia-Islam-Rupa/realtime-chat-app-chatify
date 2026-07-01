// ignore_for_file: use_build_context_synchronously

import 'package:chatify/features/friends/presentation/screens/friend_tile.dart';
import 'package:chatify/features/friends/presentation/screens/frriend_error_view.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

// ---------------------------------------------------------------------------
// Tab 0 — My Friends
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Tab 1 — Requests
// ---------------------------------------------------------------------------

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
    final query = ref.watch(findPeopleNotifierProvider).query.toLowerCase();
    final allUsersAsync = ref.watch(allUsersProvider(widget.currentUserId));
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
                        ref.read(findPeopleNotifierProvider.notifier).clear();
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
            error: (e, _) => ErrorView(message: e.toString()),
            data: (users) {
              // Filter by query client-side
              final filtered = query.isEmpty
                  ? users
                  : users
                        .where(
                          (u) =>
                              u.name.toLowerCase().contains(query) ||
                              (u.about?.toLowerCase().contains(query) ?? false),
                        )
                        .toList();

              if (filtered.isEmpty) {
                return _EmptyState(
                  icon: query.isEmpty ? Icons.people_outline : Icons.search_off,
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
// class _FriendTile extends ConsumerWidget {
//   final String friendId;
//   final String currentUserId;
//   final VoidCallback onRemove;

//   const _FriendTile({
//     required this.friendId,
//     required this.currentUserId,
//     required this.onRemove,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final profileAsync = ref.watch(profileProvider(friendId));
//     final isLoading = ref
//         .watch(friendActionsNotifierProvider)
//         .isLoadingFor(friendId);

//     return profileAsync.when(
//       loading: () => const _LoadingTile(),
//       error: (e, st) => _FallbackTile(id: friendId),
//       data: (profile) => ListTile(
//         leading: _Avatar(imageUrl: profile.imageUrl, name: profile.name),
//         title: Text(
//           profile.name,
//           style: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//         subtitle: (profile.about?.isNotEmpty ?? false)
//             ? Text(profile.about!, maxLines: 1, overflow: TextOverflow.ellipsis)
//             : null,
//         trailing: isLoading
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               )
//             : Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // ── Direct message button ─────────────────────────
//                   _MessageIconButton(otherUserId: profile.id),

//                   // ── More options ──────────────────────────────────
//                   PopupMenuButton<String>(
//                     icon: const Icon(Icons.more_vert),
//                     onSelected: (v) {
//                       if (v == 'view') {
//                         context.push(RouteNames.profileViewPath(profile.id));
//                       } else if (v == 'remove') {
//                         onRemove();
//                       }
//                     },
//                     itemBuilder: (ctx) => const [
//                       PopupMenuItem(
//                         value: 'view',
//                         child: ListTile(
//                           dense: true,
//                           leading: Icon(Icons.person_outline),
//                           title: Text('View profile'),
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                       ),
//                       PopupMenuItem(
//                         value: 'remove',
//                         child: ListTile(
//                           dense: true,
//                           leading: Icon(Icons.person_remove_outlined),
//                           title: Text('Remove friend'),
//                           contentPadding: EdgeInsets.zero,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//         onTap: () => context.push(RouteNames.profileViewPath(profile.id)),
//       ),
//     );
//   }
// }

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
        title: Text(
          profile.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: (profile.about?.isNotEmpty ?? false)
            ? Text(profile.about!, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
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
  const _FindPeopleTile({required this.profile, required this.currentUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relation = ref.watch(userRelationProvider(currentUserId, profile.id));
    final actionState = ref.watch(friendActionsNotifierProvider);

    final loadingKey = relation.requestId ?? profile.id;
    final isLoading = actionState.isLoadingFor(loadingKey);

    return ListTile(
      leading: _Avatar(imageUrl: profile.imageUrl, name: profile.name),
      title: Text(
        profile.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: (profile.about?.isNotEmpty ?? false)
          ? Text(profile.about!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : null,
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : relation.relation == UserRelation.friends
          // Already friends — show a direct message button
          ? _MessageIconButton(otherUserId: profile.id)
          : _RelationButton(relation: relation, profile: profile),
      onTap: () => context.push(RouteNames.profileViewPath(profile.id)),
    );
  }
}

/// The smart action button rendered based on [RelationInfo].
class RelationButton extends ConsumerWidget {
  final RelationInfo relation;
  final Profile profile;
  const RelationButton({
    super.key,
    required this.relation,
    required this.profile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = ref.read(friendActionsNotifierProvider.notifier);

    switch (relation.relation) {
      // ── Already friends ─────────────────────────────────────────────
      case UserRelation.friends:
        return OutlinedButton.icon(
          onPressed:
              null, // tap the tile to view profile; remove via My Friends
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
                  'Withdraw your friend request to ${profile.name}?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('No'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Cancel request'),
                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
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
