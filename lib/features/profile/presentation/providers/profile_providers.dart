import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/create_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/upload_profile_image_use_case.dart';

part 'profile_providers.g.dart';

// ---------------------------------------------------------------------------
// 1. Realtime profile stream provider (family keyed by userId)
// ---------------------------------------------------------------------------

/// Exposes a live [Profile] for [userId] as an [AsyncValue].
/// Backed by Supabase realtime — online/last_seen update in real time.
@riverpod
Stream<Profile> profile(ProfileRef ref, String userId) {
  return ref
      .watch(profileRepositoryProvider)
      .getProfileStream(userId)
      .map(
        (either) => either.fold(
          (failure) => throw Exception(failure.message),
          (p) => p,
        ),
      );
}

// ---------------------------------------------------------------------------
// 2. Form state shared by create and edit flows
// ---------------------------------------------------------------------------

/// Holds all in-progress state for the profile wizard and edit form.
/// Image file, name, about, and bio all live here so they are never
/// out of sync across steps.
class ProfileFormState {
  final File? pickedImage;
  final String? uploadedImageUrl;
  final String name;
  final String about;
  final String bio;
  final bool isSubmitting;
  final String? errorMessage;

  const ProfileFormState({
    this.pickedImage,
    this.uploadedImageUrl,
    this.name = '',
    this.about = '',
    this.bio = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  ProfileFormState copyWith({
    File? pickedImage,
    bool clearPickedImage = false,
    String? uploadedImageUrl,
    String? name,
    String? about,
    String? bio,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileFormState(
      pickedImage: clearPickedImage ? null : (pickedImage ?? this.pickedImage),
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
      name: name ?? this.name,
      about: about ?? this.about,
      bio: bio ?? this.bio,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. CreateProfileNotifier
// ---------------------------------------------------------------------------

@riverpod
class CreateProfileNotifier extends _$CreateProfileNotifier {
  @override
  ProfileFormState build() => const ProfileFormState();

  void setPickedImage(File image) =>
      state = state.copyWith(pickedImage: image, clearError: true);

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);

  void setAbout(String value) =>
      state = state.copyWith(about: value, clearError: true);

  void setBio(String value) =>
      state = state.copyWith(bio: value, clearError: true);

  /// Uploads image (if picked) then creates the profile row.
  /// Returns [true] on success so the UI can navigate away.
  Future<bool> submit(String userId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    String? imageUrl;

    if (state.pickedImage != null) {
      final uploadResult = await UploadProfileImageUseCase(
        ref.read(profileRepositoryProvider),
      )(state.pickedImage!, userId);

      final failed = uploadResult.fold(
        (failure) {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
          );
          return true;
        },
        (url) {
          imageUrl = url;
          return false;
        },
      );
      if (failed) return false;
    }

    final result =
        await CreateProfileUseCase(ref.read(profileRepositoryProvider))(
          Profile(
            id: userId,
            createdAt: DateTime.now(),
            name: state.name.trim(),
            imageUrl: imageUrl,
            about: state.about.trim().isEmpty ? null : state.about.trim(),
            bio: state.bio.trim().isEmpty ? null : state.bio.trim(),
            isOnline: true,
          ),
        );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isSubmitting: false);
        return true;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 4. EditProfileNotifier
// ---------------------------------------------------------------------------

@riverpod
class EditProfileNotifier extends _$EditProfileNotifier {
  @override
  ProfileFormState build() => const ProfileFormState();

  /// Seeds the form with an existing profile's current values.
  void load(Profile profile) {
    state = ProfileFormState(
      uploadedImageUrl: profile.imageUrl,
      name: profile.name,
      about: profile.about ?? '',
      bio: profile.bio ?? '',
    );
  }

  void setPickedImage(File image) =>
      state = state.copyWith(pickedImage: image, clearError: true);

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);

  void setAbout(String value) =>
      state = state.copyWith(about: value, clearError: true);

  void setBio(String value) =>
      state = state.copyWith(bio: value, clearError: true);

  /// Uploads new image (if changed) then updates the profile row.
  /// Returns [true] on success.
  Future<bool> submit(Profile existing) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    String? imageUrl = existing.imageUrl;

    if (state.pickedImage != null) {
      final uploadResult = await UploadProfileImageUseCase(
        ref.read(profileRepositoryProvider),
      )(state.pickedImage!, existing.id);

      final failed = uploadResult.fold(
        (failure) {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: failure.message,
          );
          return true;
        },
        (url) {
          imageUrl = url;
          return false;
        },
      );
      if (failed) return false;
    }

    final result =
        await UpdateProfileUseCase(ref.read(profileRepositoryProvider))(
          existing.copyWith(
            name: state.name.trim(),
            imageUrl: imageUrl,
            about: state.about.trim().isEmpty ? null : state.about.trim(),
            bio: state.bio.trim().isEmpty ? null : state.bio.trim(),
          ),
        );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isSubmitting: false);
        return true;
      },
    );
  }
}
