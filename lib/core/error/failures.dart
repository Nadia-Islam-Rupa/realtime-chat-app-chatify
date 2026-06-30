import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
/// Use with [dartz.Either] as the Left type.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Auth ---

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure()
      : super('User is not authenticated. Please sign in.');
}

// --- Network ---

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('The request timed out. Please try again.');
}

// --- Data ---

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// --- Storage / Media ---

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

// --- Unknown ---

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
