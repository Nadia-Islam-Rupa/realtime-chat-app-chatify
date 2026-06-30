import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_providers.dart';

/// Tab body for the Profile tab — shows the *current user's own* profile
/// as a read-only summary with an Edit button and a Log Out button.
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
              Text('Could not load profile',
                  style: theme.textTheme.titleMedium),
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

class _ProfileContent extends ConsumerWidget {
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

  Future<void> _confirmAndSignOut(BuildContext context, WidgetRef ref) async {
    // Show a confirmation dialog before signing out
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(signOutNotifierProvider.notifier).signOut();

    // The router's auth redirect will automatically send the user to /sign-in
    // once Supabase fires the sign-out event, but we also navigate immediately
    // so there's no visible delay.
    if (context.mounted) {
      context.go(RouteNames.signIn);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final signOutState = ref.watch(signOutNotifierProvider);
    final isSigningOut = signOutState.isLoading;

    // Show error snackbar if sign-out fails
    ref.listen(signOutNotifierProvider, (prev, next) {
      if (next.hasError && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${next.error}'),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

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
                colors: [AppColors.primaryDark, colorScheme.surface],
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

          // ── Name + About + actions ──────────────────────────────────────
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

                // ── Edit Profile button ──────────────────────────────
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
                  Text(profile.bio!, style: theme.textTheme.bodyMedium),
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
                const Divider(),
                const SizedBox(height: 16),

                // ── Log out button ───────────────────────────────────
                OutlinedButton.icon(
                  onPressed: isSigningOut
                      ? null
                      : () => _confirmAndSignOut(context, ref),
                  icon: isSigningOut
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.error,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: Text(isSigningOut ? 'Logging out…' : 'Log out'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

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
