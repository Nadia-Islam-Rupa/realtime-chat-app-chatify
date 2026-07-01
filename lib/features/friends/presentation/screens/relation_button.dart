import 'package:chatify/core/theme/app_colors.dart';
import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';
import 'package:chatify/features/profile/domain/entities/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
