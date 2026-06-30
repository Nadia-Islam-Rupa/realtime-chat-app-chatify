import '../../domain/entities/profile.dart';

/// Data-layer model mapping between the `profile` Supabase table and [Profile].
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.createdAt,
    required super.name,
    super.imageUrl,
    super.about,
    super.bio,
    required super.isOnline,
    super.lastSeen,
  });

  /// Creates a [ProfileModel] from a Supabase row map.
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      name: (map['name'] as String?) ?? '',        // nullable — empty string fallback
      imageUrl: map['image_url'] as String?,
      about: map['about'] as String?,
      bio: map['bio'] as String?,
      isOnline: (map['is_online'] as bool?) ?? false,
      lastSeen: map['last_seen'] != null
          ? DateTime.parse(map['last_seen'] as String)
          : null,
    );
  }

  /// Serialises this model to a Supabase-compatible map.
  /// Omits [createdAt] — let the DB default handle it on insert.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'about': about,
      'bio': bio,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  /// Converts this model to the pure domain [Profile].
  Profile toEntity() => Profile(
        id: id,
        createdAt: createdAt,
        name: name,
        imageUrl: imageUrl,
        about: about,
        bio: bio,
        isOnline: isOnline,
        lastSeen: lastSeen,
      );

  /// Creates a [ProfileModel] from a domain [Profile].
  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      createdAt: profile.createdAt,
      name: profile.name,
      imageUrl: profile.imageUrl,
      about: profile.about,
      bio: profile.bio,
      isOnline: profile.isOnline,
      lastSeen: profile.lastSeen,
    );
  }
}
