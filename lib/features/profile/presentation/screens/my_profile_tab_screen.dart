import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_providers.dart';

/// Tab body for the Profile tab — shows the *current user's own* profile
/// as a read-only summary with an Edit button.
///
/// Mounted inside the HomeShellScreen IndexedStack for tab 3.
/// No Scaffold or AppBar — provided by HomeShellScreen.
class MyProfileTabScreen extends ConsumerWidget {
  const MyProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final profileAsync = ref.watch(profileProvider(userId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Could not load profile',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
      data: (profile) => _ProfileContent(profile: profile),
    );
  }
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

class _ProfileContent extends StatelessWidget {
  final Profile profile;
  const _ProfileContent({required this.profile});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header gradient with avatar ─────────────────────────────────
          Container(
            height: 220,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: profile.imageUrl != null
                      ? NetworkImage(profile.imageUrl!)
                      : null,
                  child: profile.imageUrl == null
                      ? const Icon(Icons.person,
                          size: 56, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: profile.isOnline
                            ? AppColors.online
                            : colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      profile.isOnline ? 'Online' : 'Offline',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Name + About ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (profile.about != null && profile.about!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.about!,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Edit profile button ────────────────────────────────
                FilledButton.icon(
                  onPressed: () =>
                      context.push(RouteNames.editProfile, extra: profile),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // ── Bio ──────────────────────────────────────────────
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profile.bio!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                ],

                // ── Info rows ────────────────────────────────────────
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member since',
                  value: _formatDate(profile.createdAt),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
