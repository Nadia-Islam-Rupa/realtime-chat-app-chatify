import 'package:equatable/equatable.dart';

/// Core domain entity representing a user's profile.
/// No Supabase or Flutter types — pure domain.
class Profile extends Equatable {
  final String id;
  final DateTime createdAt;
  final String name;
  final String? imageUrl;
  final String? about;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeen;

  const Profile({
    required this.id,
    required this.createdAt,
    required this.name,
    this.imageUrl,
    this.about,
    this.bio,
    required this.isOnline,
    this.lastSeen,
  });

  Profile copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    String? imageUrl,
    String? about,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return Profile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props =>
      [id, createdAt, name, imageUrl, about, bio, isOnline, lastSeen];
}
