import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatify/features/home/presentation/providers/home_tab_provider.dart';
import 'package:chatify/features/friends/presentation/providers/friends_providers.dart';

void main() {
  // ── HomeTab provider ───────────────────────────────────────────────────────

  group('HomeTabNotifier', () {
    test('default tab is chats', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(homeTabNotifierProvider), HomeTab.chats);
    });

    test('setTab switches to the given tab', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(homeTabNotifierProvider.notifier).setTab(HomeTab.friends);
      expect(container.read(homeTabNotifierProvider), HomeTab.friends);

      container.read(homeTabNotifierProvider.notifier).setTab(HomeTab.profile);
      expect(container.read(homeTabNotifierProvider), HomeTab.profile);
    });

    test('setTabIndex switches by integer index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      for (final tab in HomeTab.values) {
        container.read(homeTabNotifierProvider.notifier).setTabIndex(tab.index);
        expect(container.read(homeTabNotifierProvider), tab);
      }
    });

    test('HomeTab.index matches enum position', () {
      expect(HomeTab.chats.index, 0);
      expect(HomeTab.friends.index, 1);
      expect(HomeTab.calls.index, 2);
      expect(HomeTab.profile.index, 3);
    });

    test('HomeTab.values has exactly 4 entries', () {
      expect(HomeTab.values.length, 4);
    });
  });

  // ── FriendActionState public API ───────────────────────────────────────────

  group('FriendActionState', () {
    test('initial state has no loading ids, no error, no success', () {
      const state = FriendActionState();
      expect(state.isLoadingFor('any-id'), isFalse);
      expect(state.error, isNull);
      expect(state.successMessage, isNull);
    });

    test('isLoadingFor returns false for arbitrary id on empty state', () {
      const state = FriendActionState();
      expect(state.isLoadingFor('user-123'), isFalse);
      expect(state.isLoadingFor(''), isFalse);
    });

    test('state with pre-populated loadingIds reports correctly', () {
      const state = FriendActionState(
        loadingIds: {'a', 'b', 'c'},
      );
      expect(state.isLoadingFor('a'), isTrue);
      expect(state.isLoadingFor('b'), isTrue);
      expect(state.isLoadingFor('c'), isTrue);
      expect(state.isLoadingFor('d'), isFalse);
    });

    test('state with error carries the message', () {
      const state = FriendActionState(error: 'Something went wrong');
      expect(state.error, 'Something went wrong');
      expect(state.successMessage, isNull);
    });

    test('state with successMessage carries the message', () {
      const state = FriendActionState(successMessage: 'Friend added!');
      expect(state.successMessage, 'Friend added!');
      expect(state.error, isNull);
    });
  });

  // ── SearchState / FindPeopleState ──────────────────────────────────────────

  group('FindPeopleState', () {
    test('default query is empty', () {
      const state = FindPeopleState();
      expect(state.query, '');
    });

    test('withQuery trims whitespace', () {
      const state = FindPeopleState();
      expect(state.withQuery('  hello  ').query, 'hello');
    });

    test('withQuery empty string stays empty', () {
      const state = FindPeopleState();
      expect(state.withQuery('').query, '');
    });

    test('withQuery preserves inner spaces', () {
      const state = FindPeopleState();
      expect(state.withQuery('john doe').query, 'john doe');
    });
  });

  // ── UserRelation ───────────────────────────────────────────────────────────

  group('RelationInfo', () {
    test('RelationInfo.none has no requestId', () {
      const info = RelationInfo(relation: UserRelation.none);
      expect(info.requestId, isNull);
      expect(info.relation, UserRelation.none);
    });

    test('RelationInfo.requestSent carries requestId', () {
      const info = RelationInfo(
          relation: UserRelation.requestSent, requestId: 'req-123');
      expect(info.requestId, 'req-123');
      expect(info.relation, UserRelation.requestSent);
    });

    test('RelationInfo.requestReceived carries requestId', () {
      const info = RelationInfo(
          relation: UserRelation.requestReceived, requestId: 'req-456');
      expect(info.requestId, 'req-456');
    });

    test('RelationInfo.friends has no requestId', () {
      const info = RelationInfo(relation: UserRelation.friends);
      expect(info.requestId, isNull);
    });

    test('UserRelation enum has all 4 values', () {
      expect(UserRelation.values.length, 4);
      expect(UserRelation.values, containsAll([
        UserRelation.none,
        UserRelation.requestSent,
        UserRelation.requestReceived,
        UserRelation.friends,
      ]));
    });
  });

  // ── FindPeopleNotifier ─────────────────────────────────────────────────────

  group('FindPeopleNotifier', () {
    test('initial state has empty query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(findPeopleNotifierProvider).query, '');
    });

    test('setQuery updates query (trimmed)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(findPeopleNotifierProvider.notifier).setQuery('  alice  ');
      expect(container.read(findPeopleNotifierProvider).query, 'alice');
    });

    test('clear resets query to empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(findPeopleNotifierProvider.notifier).setQuery('bob');
      container.read(findPeopleNotifierProvider.notifier).clear();
      expect(container.read(findPeopleNotifierProvider).query, '');
    });
  });

  // ── Widget smoke test ──────────────────────────────────────────────────────

  testWidgets('NavigationBar tab labels render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
              NavigationDestination(
                  icon: Icon(Icons.people_outline), label: 'Friends'),
              NavigationDestination(
                  icon: Icon(Icons.call_outlined), label: 'Calls'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Calls'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Tapping a NavigationBar destination calls onDestinationSelected',
      (tester) async {
    int selectedIndex = 0;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          home: Scaffold(
            body: Text('Tab $selectedIndex'),
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => setState(() => selectedIndex = i),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
                NavigationDestination(
                    icon: Icon(Icons.people_outline), label: 'Friends'),
                NavigationDestination(
                    icon: Icon(Icons.call_outlined), label: 'Calls'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tab 0'), findsOneWidget);

    await tester.tap(find.text('Friends'));
    await tester.pump();

    expect(find.text('Tab 1'), findsOneWidget);
  });
}
