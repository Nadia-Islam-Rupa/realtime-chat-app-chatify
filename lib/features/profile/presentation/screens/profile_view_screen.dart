import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/profile_providers.dart';

/// Displays another user's profile.
/// Pass [userId] via GoRouter's `extra` parameter.
class ProfileViewScreen extends ConsumerWidget {
  final String userId;

  const ProfileViewScreen({super.key, required this.userId});

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'a while ago';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(e.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error)),
            ],
          ),
        ),
        data: (profile) => CustomScrollView(
          slivers: [
            // ---- Collapsible app bar with avatar ----
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryDark,
                            colorScheme.surface,
                          ],
                        ),
                      ),
                    ),
                    // Avatar
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 64,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: profile.imageUrl != null
                                ? NetworkImage(profile.imageUrl!)
                                : null,
                            child: profile.imageUrl == null
                                ? const Icon(Icons.person,
                                    size: 64, color: AppColors.primary)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          // Online badge
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: profile.isOnline
                                      ? AppColors.online
                                      : colorScheme.outline,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                profile.isOnline
                                    ? 'Online'
                                    : 'Last seen ${_formatLastSeen(profile.lastSeen)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---- Profile info ----
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      profile.name,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    // About
                    if (profile.about != null && profile.about!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        profile.about!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Bio
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      Text('About',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(profile.bio!,
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 24),
                    ],

                    // ---- Action buttons ----
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              // TODO: wire to chat module
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Chat coming soon')),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Message'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: wire to friends module
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Friend request coming soon')),
                              );
                            },
                            icon: const Icon(Icons.person_add_outlined),
                            label: const Text('Add Friend'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
