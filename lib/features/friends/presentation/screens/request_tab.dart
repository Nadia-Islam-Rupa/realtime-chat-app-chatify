import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';
import 'package:chatify/features/friends/presentation/screens/frriend_error_view.dart';
import 'package:chatify/features/friends/presentation/screens/state_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestsTab extends ConsumerWidget {
  final String userId;
  const RequestsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRequestsProvider(userId));

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (requests) {
        if (requests.isEmpty) {
          return const EmptyState(
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
          itemBuilder: (context, i) => RequestTile(
            senderId: requests[i].senderId,
            requestId: requests[i].id,
          ),
        );
      },
    );
  }
}
