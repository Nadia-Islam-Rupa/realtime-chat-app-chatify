import 'package:chatify/core/router/route_names.dart';
import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';
import 'package:chatify/features/friends/presentation/screens/avatar_screen.dart';

import 'package:chatify/features/friends/presentation/screens/massage_icon.dart';
import 'package:chatify/features/friends/presentation/screens/relation_button.dart';
import 'package:chatify/features/profile/domain/entities/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FindPeopleTile extends ConsumerWidget {
  final Profile profile;
  final String currentUserId;
  const FindPeopleTile({
    super.key,
    required this.profile,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relation = ref.watch(userRelationProvider(currentUserId, profile.id));
    final actionState = ref.watch(friendActionsNotifierProvider);

    final loadingKey = relation.requestId ?? profile.id;
    final isLoading = actionState.isLoadingFor(loadingKey);

    return ListTile(
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
          : relation.relation == UserRelation.friends
          // Already friends — show a direct message button
          ? MessageIconButton(otherUserId: profile.id)
          : RelationButton(relation: relation, profile: profile),
      onTap: () => context.push(RouteNames.profileViewPath(profile.id)),
    );
  }
}
