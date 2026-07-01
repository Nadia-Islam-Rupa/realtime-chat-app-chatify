import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestsTabLabel extends ConsumerWidget {
  final String userId;
  const RequestsTabLabel({super.key, required this.userId});

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
