import 'package:chatify/core/router/route_names.dart';
import 'package:chatify/core/theme/app_colors.dart';
import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';
import 'package:chatify/features/friends/presentation/screens/avatar_screen.dart';
import 'package:chatify/features/friends/presentation/screens/state_tile.dart';
import 'package:chatify/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RequestTile extends ConsumerWidget {
  final String senderId;
  final String requestId;
  const RequestTile({
    super.key,
    required this.senderId,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(senderId));
    final isLoading = ref
        .watch(friendActionsNotifierProvider)
        .isLoadingFor(requestId);

    return profileAsync.when(
      loading: () => const LoadingTile(),
      error: (e, st) => FallbackTile(id: senderId),
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
