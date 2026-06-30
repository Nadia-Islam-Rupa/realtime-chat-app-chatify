import 'package:equatable/equatable.dart';

/// Core domain entity representing an authenticated user.
/// Contains only what the domain cares about — no Supabase-specific types.
class User extends Equatable {
  final String id;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, createdAt];
}
