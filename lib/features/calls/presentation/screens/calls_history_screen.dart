import 'package:flutter/material.dart';

/// Tab body for the Calls tab.
///
/// Mounted inside the HomeShellScreen IndexedStack for tab 2.
/// No Scaffold or AppBar — provided by HomeShellScreen.
///
/// TODO(calls): Replace with the real call history list once the calls
/// data layer is implemented.  Each item should show caller avatar, name,
/// call direction (in/out), duration and timestamp, with a tap-to-redial
/// action.
class CallsHistoryScreen extends StatelessWidget {
  const CallsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.call_outlined,
            size: 72,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent calls',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your call history will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
