import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';

part 'auth_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Live auth state stream
// ---------------------------------------------------------------------------

/// Emits [User?] whenever the Supabase session changes.
/// [null] means the user is signed out.
/// Consumed by the router's redirect logic and any widget that needs auth state.
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

// ---------------------------------------------------------------------------
// 2. Sign-in notifier
// ---------------------------------------------------------------------------

/// Manages the async state for the sign-in action.
/// State is [AsyncValue<void>] — loading/error/success.
@riverpod
class SignInNotifier extends _$SignInNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final useCase = SignInUseCase(ref.read(authRepositoryProvider));
    final result = await useCase(email: email, password: password);

    state = result.fold(
      (failure) => AsyncValue.error(_failureMessage(failure), StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Sign-up notifier
// ---------------------------------------------------------------------------

/// Manages the async state for the sign-up action.
@riverpod
class SignUpNotifier extends _$SignUpNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final useCase = SignUpUseCase(ref.read(authRepositoryProvider));
    final result = await useCase(email: email, password: password);

    state = result.fold(
      (failure) => AsyncValue.error(_failureMessage(failure), StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Sign-out notifier
// ---------------------------------------------------------------------------

/// Manages the async state for the sign-out action.
@riverpod
class SignOutNotifier extends _$SignOutNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> signOut() async {
    state = const AsyncValue.loading();

    final useCase = SignOutUseCase(ref.read(authRepositoryProvider));
    final result = await useCase();

    state = result.fold(
      (failure) => AsyncValue.error(_failureMessage(failure), StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _failureMessage(Failure failure) => failure.message;
