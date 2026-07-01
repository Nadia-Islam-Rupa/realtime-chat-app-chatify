// ignore_for_file: use_build_context_synchronously

import 'package:chatify/features/friends/presentation/screens/find_people_tab.dart';

import 'package:chatify/features/friends/presentation/screens/my_friend_tab.dart';
import 'package:chatify/features/friends/presentation/screens/request_tab.dart';
import 'package:chatify/features/friends/presentation/screens/request_tab_lebel.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';


import '../../../../core/theme/app_colors.dart';

import '../../../profile/domain/entities/profile.dart';

import '../providers/friends_providers.dart';

/// Friends tab body — three sub-tabs:
///   0. My Friends   – live list of accepted friends
///   1. Requests     – incoming pending requests (with badge count)
///   2. Find People  – all users shown on open, filterable, smart action button
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final colorScheme = Theme.of(context).colorScheme;

    // Global snackbars for action feedback
    ref.listen(friendActionsNotifierProvider, (prev, next) {
      if (!mounted) return;
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Column(
      children: [
        ColoredBox(
          color: colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: [
              const Tab(text: 'My Friends'),
              RequestsTabLabel(userId: userId),
              const Tab(text: 'Find People'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              MyFriendsTab(userId: userId),
              RequestsTab(userId: userId),
              FindPeopleTab(currentUserId: userId),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Requests tab label — live badge
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Tab 0 — My Friends
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Tab 1 — Requests
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Tab 2 — Find People
// ---------------------------------------------------------------------------


// ---------------------------------------------------------------------------
// Tiles
// ---------------------------------------------------------------------------

/// Incoming request tile with Accept / Reject.

/// Find People tile — shows smart action button based on current relation.

/// The smart action button rendered based on [RelationInfo].
