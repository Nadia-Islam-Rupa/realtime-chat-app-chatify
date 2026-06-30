import 'package:flutter/material.dart';

/// Tab body for the Friends tab.
///
/// Mounted inside the HomeShellScreen IndexedStack for tab 1.
/// No Scaffold or AppBar — provided by HomeShellScreen.
///
/// TODO(friends): Replace with the real friends list / tabs
/// (My Friends | Requests | Find People) once the friends data layer is ready.
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 72,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No friends yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to find and add people',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
