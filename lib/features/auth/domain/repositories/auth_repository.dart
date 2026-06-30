import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Defines the contract for all authentication operations.
/// The data layer implements this; the presentation layer depends only on this.
abstract class AuthRepository {
  /// Creates a new account with [email] and [password].
  /// Returns the newly created [User] on success.
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
  });

  /// Signs in an existing user with [email] and [password].
  /// Returns the authenticated [User] on success.
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  /// Signs out the currently authenticated user.
  Future<Either<Failure, void>> signOut();

  /// Returns the currently authenticated [User], or [UnauthenticatedFailure]
  /// if no session exists.
  Future<Either<Failure, User>> getCurrentUser();

  /// A stream of [User?] that emits whenever the auth state changes.
  /// Emits [null] when the user is signed out.
  Stream<User?> authStateChanges();
}
