/// Base class for all data-layer exceptions.
/// These are thrown by datasources and caught in repository implementations,
/// where they are mapped to [Failure] types.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

// --- Auth ---

class AuthException extends AppException {
  const AuthException(super.message);
}

class UnauthenticatedException extends AppException {
  const UnauthenticatedException()
      : super('User is not authenticated. Please sign in.');
}

// --- Network / Server ---

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class TimeoutException extends AppException {
  const TimeoutException() : super('The request timed out. Please try again.');
}

// --- Data ---

class CacheException extends AppException {
  const CacheException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

// --- Storage / Media ---

class StorageException extends AppException {
  const StorageException(super.message);
}

// --- Unknown ---

class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}
