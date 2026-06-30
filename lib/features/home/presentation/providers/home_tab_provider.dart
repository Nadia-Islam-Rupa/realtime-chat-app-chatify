import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_tab_provider.g.dart';

/// The four bottom-navigation tabs of HomeShellScreen.
enum HomeTab {
  chats,
  friends,
  calls,
  profile;
  // Note: `index` is already provided by Dart's Enum — do NOT redeclare it.
}

/// Holds the currently selected [HomeTab].
///
/// Using a Riverpod notifier (not local widget State) means any part of the
/// app — e.g. a deep-link handler, a notification tap — can switch tabs
/// programmatically without holding a [BuildContext].
///
/// Usage:
///   Read:   ref.watch(homeTabNotifierProvider)
///   Write:  ref.read(homeTabNotifierProvider.notifier).setTab(HomeTab.friends)
@Riverpod(keepAlive: true)
class HomeTabNotifier extends _$HomeTabNotifier {
  @override
  HomeTab build() => HomeTab.chats;

  /// Switch to the given [tab].
  void setTab(HomeTab tab) => state = tab;

  /// Switch to a tab by its raw integer [index].
  void setTabIndex(int index) {
    assert(index >= 0 && index < HomeTab.values.length);
    state = HomeTab.values[index];
  }
}
