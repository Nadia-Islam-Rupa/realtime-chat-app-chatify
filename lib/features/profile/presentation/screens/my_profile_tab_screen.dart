import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_providers.dart';

/// Tab body for the Profile tab — shows the *current user's own* profile
/// as a read-only summary with an Edit button, a Dark/Light mode toggle,
/// and a Log Out button.
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

    if (context.mounted) {
      context.go(RouteNames.signIn);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final signOutState = ref.watch(signOutNotifierProvider);
    final isSigningOut = signOutState.isLoading;

    // Watch theme mode so the toggle reflects current state
    final themeMode = ref.watch(themeModeProvider);
    final isCurrentlyDark = themeMode == ThemeMode.dark;

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

    // Header gradient colors based on current theme
    final gradientTop = isDark
        ? AppColors.backgroundDark
        : const Color(0xFF6B3FA0); // medium purple — visible but not black
    final gradientBottom = isDark
        ? AppColors.surfaceDark
        : AppColors.lightBg;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header gradient with avatar ─────────────────────────────────
          Container(
            height: 230,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [gradientTop, gradientBottom],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Avatar with a colored ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.primaryLight,
                    backgroundImage: profile.imageUrl != null
                        ? NetworkImage(profile.imageUrl!)
                        : null,
                    child: profile.imageUrl == null
                        ? Icon(
                            Icons.person,
                            size: 52,
                            color: colorScheme.primary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                // Online / offline chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: profile.isOnline
                        ? AppColors.online.withAlpha(40)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: profile.isOnline
                              ? AppColors.online
                              : Colors.white38,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        profile.isOnline ? 'Online' : 'Offline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
                // Name
                Text(
                  profile.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (profile.about != null && profile.about!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.about!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Edit Profile button ──────────────────────────────────
                FilledButton.icon(
                  onPressed: () =>
                      context.push(RouteNames.editProfile, extra: profile),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Dark / Light mode toggle ─────────────────────────────
                _DarkModeToggleTile(
                  isDark: isCurrentlyDark,
                  onToggle: () =>
                      ref.read(themeModeProvider.notifier).toggle(),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // ── Bio ──────────────────────────────────────────────────
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

                // ── Info rows ────────────────────────────────────────────
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member since',
                  value: _formatDate(profile.createdAt),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                // ── Log out button ───────────────────────────────────────
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
                    minimumSize: const Size.fromHeight(52),
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
// Dark / Light mode toggle tile
// ---------------------------------------------------------------------------

/// A styled tile that shows the current mode and lets the user toggle it.
class _DarkModeToggleTile extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _DarkModeToggleTile({
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLightMode = theme.brightness == Brightness.light;

    // In light mode: icon bg is a soft lavender so it stands out on white.
    // In dark mode: icon bg is the deep indigo used elsewhere in dark UI.
    final iconBg = isLightMode
        ? const Color(0xFFEDE9FF)
        : const Color(0xFF3730A3);

    final iconColor = isLightMode
        ? AppColors.primary
        : AppColors.primaryDarkMode;

    // Container background:
    // Light — white card with a visible violet border.
    // Dark  — semi-transparent surface card (existing behavior).
    final tileBg = isLightMode
        ? AppColors.lightSurface
        : colorScheme.surfaceContainerHighest;

    final borderColor = isLightMode
        ? AppColors.lightDivider
        : colorScheme.outline.withAlpha(80);

    // Track colors that are clearly distinguishable in both modes:
    // Light inactive — solid light gray so it's visible on white.
    // Dark  inactive — semi-transparent violet tint.
    final activeTrack   = AppColors.primary;
    final inactiveTrack = isLightMode
        ? const Color(0xFFE0E0E0)
        : const Color(0x448B5CF6);
    final inactiveThumb = isLightMode
        ? const Color(0xFF9E9E9E)
        : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: iconColor,
            size: 22,
          ),
        ),
        title: Text(
          isDark ? 'Dark Mode' : 'Light Mode',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          isDark ? 'Tap to switch to light' : 'Tap to switch to dark',
          style: theme.textTheme.bodySmall,
        ),
        value: isDark,
        onChanged: (_) => onToggle(),
        activeThumbColor: Colors.white,
        inactiveThumbColor: inactiveThumb,
        activeTrackColor: activeTrack,
        inactiveTrackColor: inactiveTrack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
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
