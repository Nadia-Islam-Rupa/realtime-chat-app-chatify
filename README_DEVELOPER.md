# Chatify — Developer Documentation

> Complete technical reference for contributors and maintainers.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Architecture](#3-architecture)
4. [Project Structure](#4-project-structure)
5. [Feature Modules](#5-feature-modules)
6. [State Management — Riverpod](#6-state-management--riverpod)
7. [Navigation — GoRouter](#7-navigation--gorouter)
8. [Backend — Supabase](#8-backend--supabase)
9. [Theme System](#9-theme-system)
10. [Error Handling](#10-error-handling)
11. [Environment Setup](#11-environment-setup)
12. [Running the Project](#12-running-the-project)
13. [Code Generation](#13-code-generation)
14. [Database Schema](#14-database-schema)
15. [Key Implementation Details](#15-key-implementation-details)
16. [Known Limitations & TODO](#16-known-limitations--todo)

---

## 1. Project Overview

Chatify is a WhatsApp-style real-time chat application built with Flutter and Supabase. It implements a full messaging experience including 1-to-1 chats, a friends system, call history, and user profiles — following Clean Architecture principles with a strict separation of data, domain, and presentation layers.

---

## 2. Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter 3.x (Material 3) |
| Language | Dart 3.x |
| State Management | Riverpod 2 + riverpod_annotation (code-gen) |
| Navigation | GoRouter 15 |
| Backend / Auth / DB | Supabase (PostgreSQL + Realtime + Auth + Storage) |
| Local Persistence | shared_preferences |
| Environment Vars | flutter_dotenv |
| Media Picker | image_picker |
| Error Handling | dartz (Either monad) |
| Equality | equatable |
| Date Formatting | intl |
| WebRTC Calls | flutter_webrtc |
| Permissions | permission_handler |

---

## 3. Architecture

The project follows **Clean Architecture** with three layers per feature:

```
Presentation  →  Domain  ←  Data
```

- **Domain** — pure Dart. Entities, repository interfaces, use cases. Zero Flutter or Supabase dependencies.
- **Data** — implements domain interfaces. Models (JSON ↔ entity mapping), remote data sources (Supabase), repository implementations.
- **Presentation** — Flutter widgets, Riverpod providers/notifiers that call use cases and expose `AsyncValue` state.

### Why this matters

- The domain layer can be unit-tested with no mocking of Flutter or Supabase.
- Swapping Supabase for another backend requires only changes to the `data` layer.
- Presentation code never calls Supabase directly — it always goes through the domain boundary.

### Functional Error Handling

All repository and use-case return types use `dartz.Either<Failure, T>`:

```dart
// Domain repository contract
Future<Either<Failure, User>> signIn({required String email, required String password});

// Presentation layer consumes it
final result = await useCase(email: email, password: password);
state = result.fold(
  (failure) => AsyncValue.error(failure.message, StackTrace.current),
  (_)       => const AsyncValue.data(null),
);
```

`Failure` is a sealed class hierarchy defined in `lib/core/error/failures.dart`:
`AuthFailure`, `NetworkFailure`, `ServerFailure`, `TimeoutFailure`, `StorageFailure`, `NotFoundFailure`, `ValidationFailure`, `UnknownFailure`.

---

## 4. Project Structure

```
lib/
├── main.dart                        # App entry point, ProviderScope, MyApp
├── config_supabase.dart             # Re-exports initSupabase()
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart       # Table names, bucket names, page size, timeouts
│   ├── error/
│   │   ├── exceptions.dart          # Data-layer exceptions (thrown in datasources)
│   │   └── failures.dart            # Domain-layer failures (returned via Either)
│   ├── network/
│   │   └── supabase_client_provider.dart  # Supabase init + SupabaseClient provider
│   ├── router/
│   │   ├── app_router.dart          # GoRouter config, auth redirect guard, shell
│   │   └── route_names.dart         # Route path constants
│   ├── theme/
│   │   ├── app_colors.dart          # Central color palette (light + dark)
│   │   ├── light_theme.dart         # Full Material 3 light ThemeData
│   │   ├── dark_theme.dart          # Full Material 3 dark ThemeData
│   │   └── theme_provider.dart      # Riverpod notifier + SharedPreferences persistence
│   ├── utils/
│   │   └── app_utils.dart           # Generic utilities
│   └── widgets/
│       └── app_lifecycle_observer.dart  # Tracks app foreground/background for presence
│
└── features/
    ├── auth/
    ├── profile/
    ├── home/
    ├── chat/
    ├── friends/
    └── calls/
```

Each feature follows the same internal structure:

```
features/<name>/
├── data/
│   ├── datasources/    # Remote datasource interface + Supabase implementation
│   ├── models/         # JSON-serialisable model classes (extend entities)
│   └── repositories/   # Repository implementation (datasource → Either)
├── domain/
│   ├── entities/       # Pure Dart data classes
│   ├── repositories/   # Abstract repository interface
│   └── usecases/       # Single-responsibility use case classes
└── presentation/
    ├── providers/       # Riverpod providers and notifiers
    └── screens/         # Flutter widgets
```

---

## 5. Feature Modules

### Auth (`features/auth`)

**Entities:** `User` (id, email, createdAt)

**Use cases:**
- `SignUpUseCase` — creates account via Supabase Auth
- `SignInUseCase` — signs in, returns `User`
- `SignOutUseCase` — clears the session

**Providers:**
- `authStateProvider` — `StreamProvider<User?>` wrapping `authStateChanges()`. The router's `refreshListenable` fires on every emission, triggering the redirect guard.
- `SignInNotifier`, `SignUpNotifier`, `SignOutNotifier` — `@riverpod class` notifiers exposing `AsyncValue<void>`.

**Auth flow:**
1. `_SupabaseAuthNotifier` (a `ChangeNotifier`) subscribes to `supabaseClient.auth.onAuthStateChange`.
2. On every event it calls `notifyListeners()`, which triggers GoRouter's `redirect` callback.
3. The redirect reads `authStateProvider` and `profileExistsProvider` to decide the destination.

---

### Profile (`features/profile`)

**Entity:** `Profile` (id, name, about, bio, imageUrl, isOnline, createdAt)

**Use cases:**
- `CreateProfileUseCase` — inserts a new row into the `profile` table
- `GetProfileUseCase` — fetches by user ID
- `UpdateProfileUseCase` — patches name/about/bio
- `UploadProfileImageUseCase` — uploads to Supabase Storage (`profile-pictures` bucket) and stores the public URL

**Screens:**
- `CreateProfileScreen` — shown after first sign-up, one-time setup
- `MyProfileTabScreen` — the Profile tab; shows avatar, status, edit button, dark-mode toggle, log-out button
- `EditProfileScreen` — inline editing of name/about/bio/photo
- `ProfileViewScreen` — public profile of another user (read-only)

---

### Home (`features/home`)

**Providers:**
- `HomeTabNotifier` — `@Riverpod(keepAlive: true)` notifier holding the selected `HomeTab` enum. `keepAlive: true` ensures tab state survives widget rebuilds.
- `BadgeProviders` — `unreadChatsCountProvider` and `pendingFriendRequestCountProvider` for bottom nav badges.

**Screens:**
- `HomeShellScreen` — persistent shell with `NavigationBar` + `IndexedStack` keeping all 4 tabs alive.
- `HomeScreen` — thin wrapper, mostly replaced by the shell.

**Tab sync:** When a deep link or back-button navigation lands on a tab route, `_syncTab()` schedules a `postFrameCallback` to update `homeTabNotifierProvider`, keeping the NavigationBar highlight in sync without disturbing the current build.

---

### Chat (`features/chat`)

**Entities:** `Conversation`, `Message`, `TypingStatus`

**Real-time architecture:**
The chat uses Supabase Realtime subscriptions wrapped in `StreamController`s that are exposed as `Stream<List<T>>` from the data layer. The presentation layer consumes these via Riverpod `StreamProvider`s.

**Key detail — single-subscriber streams:**
The `conversationsStream` and `messagesStream` use `StreamController` (not broadcast). This is intentional. Using `yield*` in a Riverpod `StreamProvider` would create a second subscriber, deadlocking the inner controller because `onListen` fires only once. The solution is to `return` the stream directly:

```dart
// CORRECT
@riverpod
Stream<List<Conversation>> conversations(ConversationsRef ref) {
  return ref.watch(chatRepositoryProvider).getConversationsList(user.id)...;
}

// WRONG — deadlocks single-subscriber StreamController
@riverpod
Stream<List<Conversation>> conversations(ConversationsRef ref) async* {
  yield* ref.watch(chatRepositoryProvider).getConversationsList(user.id)...;
}
```

**Providers:**
- `conversationsProvider` — `StreamProvider<List<Conversation>>`
- `messagesProvider(conversationId)` — `StreamProvider<List<Message>>`
- `typingStatusProvider(conversationId)` — `StreamProvider<List<TypingStatus>>`
- `TypingDebounceNotifier` — debounces typing events (3-second timer), writes `isTyping` to the `typing_status` table; clears on screen dispose.
- `SendMessageNotifier` — handles text and image (Supabase Storage upload) messages.
- `MarkAsReadNotifier` — marks messages read when the chat screen opens.

**Image sending flow:**
1. User picks image via `image_picker`.
2. `SendMessageNotifier.sendImage()` uploads bytes to `chat-media/{userId}/{conversationId}_{timestamp}.jpg`.
3. Gets the public URL from Supabase Storage.
4. Calls `SendMessageUseCase` with `mediaUrl` and `mediaType: 'image'`.

---

### Friends (`features/friends`)

**Entities:** `FriendRequest`, `Friend`, `BlockedUser`

**`UserRelation` enum:** `none | requestSent | requestReceived | friends`

The `userRelationProvider(currentUserId, otherUserId)` computes the relationship synchronously by reading three already-cached stream providers (friends list, sent requests, received requests). No extra network call.

**`FriendActionsNotifier`** uses a `Set<String> loadingIds` to track per-user in-flight actions independently — tapping one user's button doesn't block another's.

**Find People tab:** Loads all users once on open. Filtering is done client-side in the UI against the loaded list, avoiding repeated network calls per keystroke.

---

### Calls (`features/calls`)

**Entity:** `Call` (id, callerId, receiverId, status, startedAt, endedAt, type)

Call history is read from the `calls` Supabase table. Active calling uses `flutter_webrtc` with signaling over Supabase Realtime (channels). The in-call screen (`InCallScreen`) and incoming call screen (`IncomingCallScreen`) are implemented; signaling logic is in the call providers.

---

## 6. State Management — Riverpod

All providers use **code generation** via `riverpod_annotation` + `build_runner`. This means you never instantiate providers manually.

### Patterns used

| Pattern | When used |
|---|---|
| `@riverpod` on a function | Synchronous computed value, `FutureProvider`, or `StreamProvider` |
| `@riverpod class` extending `_$X` | Mutable notifier (`AsyncNotifier`, `Notifier`, `StreamNotifier`) |
| `@Riverpod(keepAlive: true)` | Providers that must survive widget rebuilds (router, tab state) |
| Family providers `provider(param)` | Keyed by ID — messages per conversation, profile per user |

### Reading providers

```dart
// In a ConsumerWidget / ConsumerStatefulWidget
ref.watch(provider)        // rebuild on change
ref.read(provider)         // one-shot read, don't watch
ref.listen(provider, ...)  // side effects (snackbars, navigation)
```

### Generated files

Every file with `part 'foo.g.dart'` has a generated counterpart produced by `build_runner`. Never edit `.g.dart` files manually.

---

## 7. Navigation — GoRouter

### Route constants (`route_names.dart`)

All route paths are string constants in `RouteNames`. Never hardcode path strings in widgets.

### Shell pattern

`ShellRoute` wraps the four tab routes and renders `HomeShellScreen` as the persistent outer shell. The shell uses `IndexedStack` instead of go_router's child rendering so all tab bodies stay mounted and preserve their scroll state.

### Auth redirect guard

```dart
redirect: (context, state) async {
  final user = ref.read(authStateProvider).valueOrNull;
  if (!isAuthenticated) return RouteNames.signIn;
  if (isOnAuthRoute) {
    final hasProfile = await ref.read(profileExistsProvider(user.id).future);
    return hasProfile ? RouteNames.chats : RouteNames.createProfile;
  }
  return null; // no redirect
}
```

The guard runs on every navigation event. `refreshListenable` is wired to Supabase's auth stream so it re-runs automatically on sign-in/sign-out.

### Passing data between routes

Use GoRouter's `extra` parameter for complex objects:

```dart
context.push(RouteNames.editProfile, extra: profile);
// Receiving:
final profile = state.extra as Profile;
```

---

## 8. Backend — Supabase

### Initialisation (`supabase_client_provider.dart`)

- Credentials loaded from `.env` via `flutter_dotenv`.
- Fallback hardcoded constants used when `.env` asset is unavailable.
- Hot-restart safe: checks `Supabase.instance.client` before calling `initialize()`.
- `initSupabase()` is called once in `main()` before `runApp()`.

### Realtime

Supabase Realtime subscriptions use PostgreSQL logical replication. The data source opens a channel subscription using `.stream()` or `.on()` depending on the table. Subscriptions are cleaned up when the Riverpod provider is disposed.

### Storage

Two buckets:
- `profile-pictures` — user avatar images
- `chat-media` — images sent in chat

Files are uploaded with a path of `{userId}/{filename}` and accessed via public URLs.

### Presence / online status

`AppLifecycleObserver` (`core/widgets/app_lifecycle_observer.dart`) listens to `AppLifecycleState` changes and updates the `is_online` column in the `profile` table when the app goes to foreground or background.

---

## 9. Theme System

### Files

| File | Purpose |
|---|---|
| `app_colors.dart` | Single source of truth for all color constants (light + dark) |
| `light_theme.dart` | Complete `ThemeData` for light mode |
| `dark_theme.dart` | Complete `ThemeData` for dark mode |
| `theme_provider.dart` | Riverpod `NotifierProvider` with `SharedPreferences` persistence |

### Color Palette

**Light mode**
- Primary: `#6C63FF` (Vibrant Purple)
- Secondary: `#FF7A59` (Coral Orange)
- Accent: `#2DD4BF` (Turquoise)
- Background: `#F4F7FC`, Surface: `#FFFFFF`
- Text: `#1E293B` / `#64748B`

**Dark mode**
- Background: `#0F172A`, Surface: `#1E293B`, Card: `#273549`
- Primary: `#8B7CFF`, Secondary: `#FF9B71`, Accent: `#4FD1C5`
- Text: `#FFFFFF` / `#CBD5E1`

### ThemeModeNotifier

```dart
// lib/core/theme/theme_provider.dart
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadFromPrefs(); // async — sets state after frame
    return ThemeMode.light; // immediate default
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    await prefs.setString('theme_mode', next == ThemeMode.dark ? 'dark' : 'light');
  }
}
```

`main.dart` consumes it:
```dart
themeMode: ref.watch(themeModeProvider),
```

The UI toggle in `MyProfileTabScreen` is a `SwitchListTile` inside `_DarkModeToggleTile` that calls `ref.read(themeModeProvider.notifier).toggle()`.

### Component theming

Every Material component is themed in the `ThemeData` — nothing is hardcoded in widgets. Components covered: AppBar, NavigationBar, all button types (`FilledButton`, `ElevatedButton`, `OutlinedButton`, `TextButton`), InputDecoration, Card, ListTile, Chip, FAB, Divider, Dialog, BottomSheet, SnackBar, Switch, Badge, and the full `TextTheme`.

---

## 10. Error Handling

### Two-layer system

**Data layer** — throws typed exceptions (`AppException`, `AuthException`, `NetworkException`, etc.) defined in `core/error/exceptions.dart`.

**Domain layer** — repository implementations catch exceptions and map them to `Failure` subclasses, returning `Either<Failure, T>`. Exceptions never escape past the repository.

**Presentation layer** — use cases return `Either`; notifiers fold to `AsyncValue.error(failure.message, ...)`. Widgets react to `AsyncValue` states with loading spinners, error messages, and retry buttons.

### SnackBar errors

Riverpod `ref.listen` is the standard pattern for showing error snackbars:

```dart
ref.listen(signOutNotifierProvider, (prev, next) {
  if (next.hasError && next.error != prev?.error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${next.error}')),
    );
  }
});
```

---

## 11. Environment Setup

### Prerequisites

- Flutter SDK `^3.11.5`
- Dart SDK `^3.11.5`
- A Supabase project (free tier works)

### `.env` file

Create `.env` at the project root (already in `.gitignore`):

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

The `.env.example` file documents the required variables.

### Dependencies

```bash
flutter pub get
```

---

## 12. Running the Project

```bash
# Run on connected device / emulator
flutter run

# Run on a specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## 13. Code Generation

This project uses `build_runner` for:
- `riverpod_generator` — generates `_$ClassName` base classes and `.g.dart` parts
- Riverpod provider type-safe factories

**Run once after pulling changes or adding new providers:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Watch mode during development:**

```bash
dart run build_runner watch --delete-conflicting-outputs
```

**Files that require generation** (have `part 'foo.g.dart'`):
- `app_router.dart`
- `supabase_client_provider.dart`
- All `*_providers.dart` files
- All `*_data_source.dart` files
- All `*_repository_impl.dart` files

---

## 14. Database Schema

### `profile` table

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | FK → `auth.users.id` |
| `name` | `text` | Display name |
| `about` | `text` | Short tagline |
| `bio` | `text` | Longer description |
| `image_url` | `text` | Public URL from Storage |
| `is_online` | `bool` | Updated by `AppLifecycleObserver` |
| `created_at` | `timestamptz` | Auto-set on insert |

### `conversations` table

| Column | Type |
|---|---|
| `id` | `uuid` |
| `participant_one` | `uuid` FK profile |
| `participant_two` | `uuid` FK profile |
| `last_message` | `text` |
| `last_message_at` | `timestamptz` |
| `unread_count_one` | `int` |
| `unread_count_two` | `int` |

### `messages` table

| Column | Type |
|---|---|
| `id` | `uuid` |
| `conversation_id` | `uuid` FK conversations |
| `sender_id` | `uuid` FK profile |
| `content` | `text` |
| `media_url` | `text` nullable |
| `media_type` | `text` nullable (`image`, `video`) |
| `is_read` | `bool` |
| `created_at` | `timestamptz` |

### `friend_requests` table

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | |
| `sender_id` | `uuid` | |
| `receiver_id` | `uuid` | |
| `status` | `text` | `pending`, `accepted`, `rejected` |
| `created_at` | `timestamptz` | |

### `friends` table

| Column | Type |
|---|---|
| `id` | `uuid` |
| `user_id` | `uuid` |
| `friend_id` | `uuid` |
| `created_at` | `timestamptz` |

### `typing_status` table

| Column | Type |
|---|---|
| `conversation_id` | `uuid` |
| `user_id` | `uuid` |
| `is_typing` | `bool` |
| `updated_at` | `timestamptz` |

### `calls` table

| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | |
| `caller_id` | `uuid` | |
| `receiver_id` | `uuid` | |
| `status` | `text` | `ringing`, `active`, `ended`, `missed` |
| `type` | `text` | `audio`, `video` |
| `started_at` | `timestamptz` | |
| `ended_at` | `timestamptz` | |

---

## 15. Key Implementation Details

### IndexedStack tab preservation

`HomeShellScreen` uses `IndexedStack` rather than go_router's own child swapping. This keeps all 4 tab widgets mounted at all times, preserving scroll positions, loaded data, and stream subscriptions across tab switches.

```dart
body: IndexedStack(index: tabIndex, children: tabBodies),
```

### `keepAlive: true` on `HomeTabNotifier`

The tab notifier is annotated with `@Riverpod(keepAlive: true)` so the selected tab index is not reset when the widget tree rebuilds (e.g. theme change).

### TypingDebounceNotifier lifecycle

The notifier tracks a `bool _disposed` flag and a `Timer?`. On dispose (when the chat screen closes), `clearTyping()` cancels the timer and sends a final `isTyping: false` event to prevent stale typing indicators.

### Profile existence check in router

`profileExistsProvider(userId)` is a `FutureProvider` that queries Supabase with `.maybeSingle()`. It returns `false` rather than throwing on errors to keep the redirect safe. The router awaits it during redirect — this is safe because GoRouter supports async redirects.

### Hot-restart safety

`initSupabase()` wraps `Supabase.initialize()` in a try-catch. On hot restart, `Supabase.instance.client` succeeds (no `StateError`) so the catch block is hit and re-initialization is skipped.

---

## 16. Known Limitations & TODO

- **Settings screen** — placeholder ("coming soon") exists in the router.
- **Group chats** — schema and UI not yet implemented.
- **Push notifications** — no FCM/APNs integration yet.
- **WebRTC signaling** — call providers are scaffolded; full peer connection and signaling flow over Supabase Realtime channels is partially implemented.
- **Media viewer** — full-screen image/video viewer not yet built.
- **Blocked users UI** — domain use cases exist (`block_user_use_case`, `unblock_user_use_case`) but no UI surface.
- **Pagination** — `AppConstants.defaultPageSize = 20` is defined but not applied consistently in all lists.
- **Offline support** — no local caching; all data fetched from Supabase on every open.
- **Tests** — integration test scaffolding exists in `test/`; unit test coverage is minimal.
.