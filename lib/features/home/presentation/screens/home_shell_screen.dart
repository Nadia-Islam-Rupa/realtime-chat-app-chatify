import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../calls/presentation/screens/calls_history_screen.dart';
import '../../../chat/presentation/screens/conversations_list_screen.dart';
import '../../../friends/presentation/screens/friends_screen.dart';
import '../../../profile/presentation/screens/my_profile_tab_screen.dart';
import '../providers/badge_providers.dart';
import '../providers/home_tab_provider.dart';

/// The authenticated shell of the app.
///
/// Wraps the four main tabs inside a [Scaffold] with a Material 3
/// [NavigationBar].  The tab bodies are kept alive via [IndexedStack] so
/// scroll positions and state are preserved when switching tabs.
///
/// Tab index is managed by [homeTabNotifierProvider] (not local State) so
/// other parts of the app can switch tabs programmatically, e.g.:
///   ref.read(homeTabNotifierProvider.notifier).setTab(HomeTab.friends)
class HomeShellScreen extends ConsumerWidget {
  /// The child widget provided by go_router's [ShellRoute].
  /// We ignore it — we use our own IndexedStack approach instead.
  const HomeShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(homeTabNotifierProvider);
    final tabIndex = currentTab.index;

    // ── Badge counts ────────────────────────────────────────────────────────
    final unreadChats =
        ref.watch(unreadChatsCountProvider).valueOrNull ?? 0;
    final pendingRequests =
        ref.watch(pendingFriendRequestCountProvider).valueOrNull ?? 0;

    // ── Tab bodies (kept alive in IndexedStack) ──────────────────────────────
    const tabBodies = [
      ConversationsListScreen(),
      FriendsScreen(),
      CallsHistoryScreen(),
      MyProfileTabScreen(),
    ];

    return Scaffold(
      // ── Per-tab AppBar ───────────────────────────────────────────────────
      appBar: _buildAppBar(context, ref, currentTab),

      // ── Tab content — IndexedStack preserves state ───────────────────────
      body: IndexedStack(
        index: tabIndex,
        children: tabBodies,
      ),

      // ── Bottom navigation bar ────────────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (i) {
          ref.read(homeTabNotifierProvider.notifier).setTabIndex(i);
          // Also keep go_router location in sync with the shell sub-route
          final routes = [
            RouteNames.chats,
            RouteNames.friends,
            RouteNames.calls,
            RouteNames.myProfile,
          ];
          context.go(routes[i]);
        },
        destinations: [
          // ── 0 · Chats ──────────────────────────────────────────────────
          NavigationDestination(
            icon: _BadgeIcon(
              icon: const Icon(Icons.chat_bubble_outline),
              count: unreadChats,
            ),
            selectedIcon: _BadgeIcon(
              icon: const Icon(Icons.chat_bubble),
              count: unreadChats,
            ),
            label: 'Chats',
          ),

          // ── 1 · Friends ────────────────────────────────────────────────
          NavigationDestination(
            icon: _BadgeIcon(
              icon: const Icon(Icons.people_outline),
              count: pendingRequests,
            ),
            selectedIcon: _BadgeIcon(
              icon: const Icon(Icons.people),
              count: pendingRequests,
            ),
            label: 'Friends',
          ),

          // ── 2 · Calls ──────────────────────────────────────────────────
          const NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call),
            label: 'Calls',
          ),

          // ── 3 · Profile ────────────────────────────────────────────────
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ── Per-tab AppBar factory ─────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    HomeTab tab,
  ) {
    switch (tab) {
      case HomeTab.chats:
        return _ChatsAppBar();
      case HomeTab.friends:
        return _FriendsAppBar();
      case HomeTab.calls:
        return _CallsAppBar();
      case HomeTab.profile:
        return _ProfileAppBar();
    }
  }
}

// ── Tab AppBar widgets ─────────────────────────────────────────────────────

/// Chats tab: app name on left, search + compose icons on right.
class _ChatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Chatify',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        // Search conversations
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search conversations',
          onPressed: () {
            // TODO(chat): open conversation search overlay
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Search coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        // Compose — opens Find People inside the Friends tab
        Consumer(
          builder: (context, ref, _) => IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Find people',
            onPressed: () {
              ref
                  .read(homeTabNotifierProvider.notifier)
                  .setTab(HomeTab.friends);
              context.go(RouteNames.friends);
            },
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// Friends tab: "Friends" title + add-friend icon.
class _FriendsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _FriendsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Friends'),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_search_outlined),
          tooltip: 'Find people',
          onPressed: () {
            // TODO(friends): switch to Find People sub-tab
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Find people coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// Calls tab: "Calls" title, no extra actions yet.
class _CallsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CallsAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Calls'),
    );
  }
}

/// Profile tab: no title, settings gear aligned right.
class _ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      // No title on profile tab — content is self-describing
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
          onPressed: () {
            // TODO(settings): context.push(RouteNames.settings)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings coming soon'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ── Badge icon helper ──────────────────────────────────────────────────────

/// Wraps an icon with a small numeric badge when [count] > 0.
class _BadgeIcon extends StatelessWidget {
  final Widget icon;
  final int count;

  const _BadgeIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return icon;
    return Badge(
      label: Text(count > 99 ? '99+' : count.toString()),
      child: icon,
    );
  }
}
