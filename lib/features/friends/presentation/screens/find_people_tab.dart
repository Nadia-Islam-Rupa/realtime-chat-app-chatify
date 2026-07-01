import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';
import 'package:chatify/features/friends/presentation/screens/find_people_tile.dart';
import 'package:chatify/features/friends/presentation/screens/frriend_error_view.dart';
import 'package:chatify/features/friends/presentation/screens/state_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FindPeopleTab extends ConsumerStatefulWidget {
  final String currentUserId;
  const FindPeopleTab({super.key, required this.currentUserId});

  @override
  ConsumerState<FindPeopleTab> createState() => _FindPeopleTabState();
}

class _FindPeopleTabState extends ConsumerState<FindPeopleTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(findPeopleNotifierProvider).query.toLowerCase();
    final allUsersAsync = ref.watch(allUsersProvider(widget.currentUserId));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Search / filter bar ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by name…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(findPeopleNotifierProvider.notifier).clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            onChanged: (v) {
              setState(() {}); // refresh clear button visibility
              ref.read(findPeopleNotifierProvider.notifier).setQuery(v);
            },
          ),
        ),

        // ── User list ────────────────────────────────────────────────────
        Expanded(
          child: allUsersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ErrorView(message: e.toString()),
            data: (users) {
              // Filter by query client-side
              final filtered = query.isEmpty
                  ? users
                  : users
                        .where(
                          (u) =>
                              u.name.toLowerCase().contains(query) ||
                              (u.about?.toLowerCase().contains(query) ?? false),
                        )
                        .toList();

              if (filtered.isEmpty) {
                return EmptyState(
                  icon: query.isEmpty ? Icons.people_outline : Icons.search_off,
                  title: query.isEmpty
                      ? 'No other users yet'
                      : 'No results for "$query"',
                  subtitle: query.isEmpty
                      ? 'Other users will appear here once they sign up'
                      : 'Try a different name',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, i) => FindPeopleTile(
                  profile: filtered[i],
                  currentUserId: widget.currentUserId,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
