import 'package:chatify/core/router/route_names.dart';

import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';
import 'package:chatify/features/friends/presentation/screens/avatar_screen.dart';
import 'package:chatify/features/friends/presentation/screens/massage_icon.dart';
import 'package:chatify/features/friends/presentation/screens/state_tile.dart';
import 'package:chatify/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FriendTile extends ConsumerWidget {
  final String friendId;
  final String currentUserId;
  final VoidCallback onRemove;

  const FriendTile({
    super.key,
    required this.friendId,
    required this.currentUserId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(friendId));
    final isLoading = ref
        .watch(friendActionsNotifierProvider)
        .isLoadingFor(friendId);

    return profileAsync.when(
      loading: () => const LoadingTile(),
      error: (e, st) => FallbackTile(id: friendId),
      data: (profile) => ListTile(
        leading: Avatar(imageUrl: profile.imageUrl, name: profile.name),
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
                  // ── Direct message button ─────────────────────────
                  MessageIconButton(otherUserId: profile.id),

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
