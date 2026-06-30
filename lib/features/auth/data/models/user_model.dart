import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/entities/user.dart';

/// Data-layer model that maps between [sb.User] (Supabase) and the domain [User].
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.createdAt,
  });

  /// Creates a [UserModel] from a Supabase [sb.User].
  factory UserModel.fromSupabaseUser(sb.User supabaseUser) {
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      createdAt: DateTime.tryParse(supabaseUser.createdAt) ?? DateTime.now(),
    );
  }

  /// Converts this model back to the domain entity.
  User toEntity() => User(id: id, email: email, createdAt: createdAt);
}
