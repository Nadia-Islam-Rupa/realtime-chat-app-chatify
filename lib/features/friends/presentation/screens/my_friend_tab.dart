import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';
import 'package:chatify/features/friends/presentation/screens/friend_tile.dart';
import 'package:chatify/features/friends/presentation/screens/frriend_error_view.dart';
import 'package:chatify/features/friends/presentation/screens/state_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyFriendsTab extends ConsumerWidget {
  final String userId;
  const MyFriendsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsListProvider(userId));

    return friendsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (friends) {
        if (friends.isEmpty) {
          return const EmptyState(
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
          itemBuilder: (context, i) => FriendTile(
            friendId: friends[i].friendId,
            currentUserId: userId,
            onRemove: () => _confirmRemove(context, ref, friends[i].friendId),
          ),
        );
      },
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    String friendId,
  ) async {
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
