import 'package:flutter/material.dart';

class LoadingTile extends StatelessWidget {
  const LoadingTile({super.key});
  @override
  Widget build(BuildContext context) => const ListTile(
    leading: CircleAvatar(child: Icon(Icons.person)),
    title: Text('Loading…'),
  );
}

class FallbackTile extends StatelessWidget {
  final String id;
  const FallbackTile({super.key, required this.id});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: const CircleAvatar(child: Icon(Icons.person)),
    title: Text(id),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
