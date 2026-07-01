# 💬 Chatify

> A modern, real-time chat application built with Flutter and Supabase.  
> Colorful, fast, and clean — with full dark/light mode support.

---

## Table of Contents

1. [What is Chatify?](#what-is-chatify)
2. [Features](#features)
3. [Screenshots](#screenshots)
4. [Tech Stack](#tech-stack)
5. [Architecture](#architecture)
6. [Project Structure](#project-structure)
7. [Database Schema](#database-schema)
8. [Theme System](#theme-system)
9. [Getting Started](#getting-started)
10. [Running the App](#running-the-app)
11. [Code Generation](#code-generation)
12. [Platform Support](#platform-support)
13. [Roadmap](#roadmap)
14. [FAQ](#faq)

---

## What is Chatify?

Chatify is a WhatsApp-style messaging app built entirely with Flutter on the frontend and Supabase on the backend. It supports real-time 1-to-1 messaging, a friends system with requests, call history, and fully customizable user profiles.

The app follows **Clean Architecture** — every feature is split into data, domain, and presentation layers so the codebase stays maintainable and testable as it grows.

---

## Features

### 💬 Messaging
- Real-time 1-to-1 chat powered by Supabase Realtime
- Send text messages and images
- Typing indicator with 3-second debounce
- Read receipts — see when messages are read
- Unread message badge on the chat tab

### 👥 Friends
- Search for users by name (Find People)
- Send, cancel, accept, and reject friend requests
- Remove existing friends
- Smart relationship button — always shows the right action (Add / Requested / Accept / Friends)
- Incoming request badge on the Friends tab

### 📞 Calls
- Call history log (audio and video)
- Incoming call screen
- In-call screen (WebRTC-powered)

### 👤 Profile
- Set display name, tagline, and bio
- Upload a profile photo from gallery or camera
- Live online/offline status indicator
- View any user's public profile

### 🎨 Appearance
- **Dark / Light mode toggle** in the Profile tab — saved across restarts
- Vibrant purple, coral, and turquoise color palette
- Full Material 3 design — rounded corners, consistent spacing, themed components

### 🔐 Account
- Email sign-up and sign-in
- Persistent session — stay logged in across restarts
- Confirmation dialog before sign-out

---

## Screenshots

| Light Mode | Dark Mode |
|---|---|
| White background · vibrant purple accents | Deep navy background · soft readable colors |
| `#F4F7FC` background · `#6C63FF` primary | `#0F172A` background · `#8B7CFF` primary |

> Both themes are applied instantly via the toggle in the Profile tab and persist across restarts.

---

## Tech Stack

| Concern | Technology |
|---|---|
| UI Framework | Flutter 3.x — Material 3 |
| Language | Dart 3.x |
| State Management | Riverpod 2 + `riverpod_annotation` (code-gen) |
| Navigation | GoRouter 15 |
| Backend | Supabase — PostgreSQL + Realtime + Auth + Storage |
| Local Storage | `shared_preferences` |
| Environment Config | `flutter_dotenv` |
| Media Picker | `image_picker` |
| Error Handling | `dartz` — `Either<Failure, T>` monad |
| Equality | `equatable` |
| Date Formatting | `intl` |
| Video / Audio Calls | `flutter_webrtc` |
| Permissions | `permission_handler` |

---

## Architecture

Chatify uses **Clean Architecture** with three layers inside every feature:

```
Presentation  ──►  Domain  ◄──  Data
```

```
features/<name>/
├── data/
│   ├── datasources/    # Supabase calls — raw network operations
│   ├── models/         # JSON ↔ entity mapping
│   └── repositories/   # Catches exceptions, returns Either<Failure, T>
├── domain/
│   ├── entities/       # Pure Dart data classes — no Flutter, no Supabase
│   ├── repositories/   # Abstract interfaces (contracts)
│   └── usecases/       # One class, one job
└── presentation/
    ├── providers/       # Riverpod notifiers — expose AsyncValue state
    └── screens/         # Flutter widgets
```

**Why this structure?**

- The **domain layer** has zero dependencies on Flutter or Supabase — it can be unit-tested in isolation.
- The **data layer** is the only place Supabase is imported. Swapping backends only touches this layer.
- The **presentation layer** never calls Supabase directly — it calls use cases.

### Error Handling

All repository methods return `Either<Failure, T>` from the `dartz` package:

```dart
// Repository contract (domain layer)
Future<Either<Failure, User>> signIn({
  required String email,
  required String password,
});

// Notifier consumes it (presentation layer)
final result = await useCase(email: email, password: password);
state = result.fold(
  (failure) => AsyncValue.error(failure.message, StackTrace.current),
  (_)       => const AsyncValue.data(null),
);
```

`Failure` subclasses: `AuthFailure`, `NetworkFailure`, `ServerFailure`, `TimeoutFailure`, `StorageFailure`, `NotFoundFailure`, `ValidationFailure`, `UnknownFailure`.

---

## Project Structure

```
lib/
├── main.dart                          # Entry point — ProviderScope, MyApp, theme wiring
├── config_supabase.dart               # Re-exports initSupabase()
│
├── core/
│   ├── constants/app_constants.dart   # Table names, bucket names, timeouts, page size
│   ├── error/
│   │   ├── exceptions.dart            # Data-layer typed exceptions
│   │   └── failures.dart              # Domain-layer Failure sealed hierarchy
│   ├── network/
│   │   └── supabase_client_provider.dart  # Supabase init + SupabaseClient provider
│   ├── router/
│   │   ├── app_router.dart            # GoRouter, auth redirect guard, ShellRoute
│   │   └── route_names.dart           # All route path constants in one place
│   ├── theme/
│   │   ├── app_colors.dart            # Single source of truth for all colors
│   │   ├── light_theme.dart           # Full Material 3 light ThemeData
│   │   ├── dark_theme.dart            # Full Material 3 dark ThemeData
│   │   └── theme_provider.dart        # Riverpod notifier + SharedPrefs persistence
│   ├── utils/app_utils.dart
│   └── widgets/app_lifecycle_observer.dart  # Online/offline presence tracker
│
└── features/
    ├── auth/        # Sign in, sign up, sign out
    ├── profile/     # Create, view, edit profile + photo upload
    ├── home/        # Shell screen, tab state, unread badges
    ├── chat/        # Conversations list, chat screen, messages, typing
    ├── friends/     # Friends list, requests, find people, relation logic
    └── calls/       # Call history, incoming call, in-call screen
```

---

## Database Schema

### `profile`
| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | Primary key — matches `auth.users.id` |
| `name` | `text` | Display name |
| `about` | `text` | Short tagline shown on profile |
| `bio` | `text` | Longer description |
| `image_url` | `text` | Public URL from Supabase Storage |
| `is_online` | `bool` | Updated by `AppLifecycleObserver` |
| `created_at` | `timestamptz` | Auto-set on insert |

### `conversations`
| Column | Type |
|---|---|
| `id` | `uuid` |
| `participant_one` | `uuid` FK → profile |
| `participant_two` | `uuid` FK → profile |
| `last_message` | `text` |
| `last_message_at` | `timestamptz` |
| `unread_count_one` | `int` |
| `unread_count_two` | `int` |

### `messages`
| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | |
| `conversation_id` | `uuid` FK | |
| `sender_id` | `uuid` FK | |
| `content` | `text` | Empty string for image-only messages |
| `media_url` | `text` | nullable |
| `media_type` | `text` | `image` or `video` |
| `is_read` | `bool` | |
| `created_at` | `timestamptz` | |

### `friend_requests`
| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | |
| `sender_id` | `uuid` | |
| `receiver_id` | `uuid` | |
| `status` | `text` | `pending` · `accepted` · `rejected` |
| `created_at` | `timestamptz` | |

### `friends`
| Column | Type |
|---|---|
| `id` | `uuid` |
| `user_id` | `uuid` |
| `friend_id` | `uuid` |
| `created_at` | `timestamptz` |

### `typing_status`
| Column | Type |
|---|---|
| `conversation_id` | `uuid` |
| `user_id` | `uuid` |
| `is_typing` | `bool` |
| `updated_at` | `timestamptz` |

### `calls`
| Column | Type | Notes |
|---|---|---|
| `id` | `uuid` | |
| `caller_id` | `uuid` | |
| `receiver_id` | `uuid` | |
| `status` | `text` | `ringing` · `active` · `ended` · `missed` |
| `type` | `text` | `audio` · `video` |
| `started_at` | `timestamptz` | |
| `ended_at` | `timestamptz` | |

---

## Theme System

Chatify ships with a complete two-theme design system. All colors live in one file and every component is themed — nothing is hardcoded in widgets.

### Color Palette

| Token | Light | Dark |
|---|---|---|
| Primary | `#6C63FF` Vibrant Purple | `#8B7CFF` |
| Secondary | `#FF7A59` Coral Orange | `#FF9B71` |
| Accent | `#2DD4BF` Turquoise | `#4FD1C5` |
| Background | `#F4F7FC` | `#0F172A` |
| Surface | `#FFFFFF` | `#1E293B` |
| Card | — | `#273549` |
| Text Primary | `#1E293B` | `#FFFFFF` |
| Text Secondary | `#64748B` | `#CBD5E1` |

### Switching Themes

The theme mode is managed by `ThemeModeNotifier` (Riverpod) and persisted with `shared_preferences`. The toggle lives in the **Profile tab** — a single tap switches the whole app instantly and the choice is remembered across restarts.

```dart
// Toggle dark/light anywhere in the widget tree
ref.read(themeModeProvider.notifier).toggle();
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.5`
- Dart SDK `^3.11.5`
- A [Supabase](https://supabase.com) project (free tier is fine)

### 1 · Clone the repo

```bash
git clone https://github.com/your-username/chatify.git
cd chatify
```

### 2 · Create your `.env` file

Copy the example and fill in your Supabase credentials:

```bash
cp .env.example .env
```

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Find these values in your Supabase dashboard → **Project Settings → API**.

### 3 · Install dependencies

```bash
flutter pub get
```

### 4 · Run code generation

This project uses `riverpod_generator` + `build_runner`. The generated `.g.dart` files must exist before you can run the app:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5 · Set up the database

Run the SQL in your Supabase SQL editor to create all required tables (`profile`, `conversations`, `messages`, `friend_requests`, `friends`, `typing_status`, `calls`) and enable Realtime on the `messages` and `typing_status` tables.

Create two Storage buckets:
- `profile-pictures` — public
- `chat-media` — public

---

## Running the App

```bash
# Run in debug mode (any connected device)
flutter run

# Run on a specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Build release APK
flutter build apk --release

# Build release iOS
flutter build ios --release
```

---

## Code Generation

Every file that has `part 'foo.g.dart'` at the top needs a generated counterpart. **Never edit `.g.dart` files manually** — they are overwritten on every build run.

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (rebuilds automatically on save)
dart run build_runner watch --delete-conflicting-outputs
```

Files that trigger generation:
- `lib/core/router/app_router.dart`
- `lib/core/network/supabase_client_provider.dart`
- All `*_providers.dart` files
- All `*_remote_data_source.dart` files
- All `*_repository_impl.dart` files

---

## Platform Support

| Platform | Status |
|---|---|
| Android | ✅ Fully supported |
| iOS | ✅ Fully supported |
| Web | 🔧 Experimental |
| macOS | 🔧 Experimental |
| Linux | 🔧 Experimental |
| Windows | 🔧 Experimental |

---

## Roadmap

- [ ] Push notifications (FCM / APNs)
- [ ] Group chats
- [ ] Full-screen media viewer
- [ ] Settings screen with notification preferences
- [ ] Message reactions and replies
- [ ] Voice messages
- [ ] Blocked users UI
- [ ] Pagination for long chat histories
- [ ] Offline caching

---

## FAQ

**Why Riverpod with code generation instead of plain providers?**  
Code-gen providers are type-safe, auto-dispose by default, and remove boilerplate. The `riverpod_annotation` approach also makes provider families (keyed by ID) cleaner to write.

**Why `IndexedStack` for tabs instead of go_router's built-in tab handling?**  
`IndexedStack` keeps all four tab widgets mounted at all times. This preserves scroll positions, live stream subscriptions, and loaded data when switching tabs — behavior that go_router's child swapping would lose.

**Why `Either<Failure, T>` instead of just throwing exceptions?**  
`Either` makes error paths explicit in the type signature. The presentation layer is forced to handle both cases at compile time — you can't accidentally ignore an error.

**What happens if the `.env` file is missing?**  
The app falls back to hardcoded credentials in `supabase_client_provider.dart`. For production builds, always supply a real `.env`.

**How do I add a new feature?**  
Follow the Clean Architecture pattern: create a `domain/entities/`, `domain/repositories/`, `domain/usecases/`, then `data/datasources/`, `data/models/`, `data/repositories/`, and finally `presentation/providers/` + `presentation/screens/`. Run `build_runner` after adding new providers.
