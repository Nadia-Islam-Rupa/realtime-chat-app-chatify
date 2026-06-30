import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_providers.dart';

/// Lets the current user edit their own profile.
/// [profile] is passed from the caller (the home screen / settings).
class EditProfileScreen extends ConsumerStatefulWidget {
  final Profile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _aboutController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _aboutController = TextEditingController(text: widget.profile.about ?? '');
    _bioController = TextEditingController(text: widget.profile.bio ?? '');

    // Seed the notifier with existing values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editProfileNotifierProvider.notifier).load(widget.profile);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Image picker
  // ---------------------------------------------------------------------------

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) {
      ref
          .read(editProfileNotifierProvider.notifier)
          .setPickedImage(File(picked.path));
    }
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    final notifier = ref.read(editProfileNotifierProvider.notifier);
    notifier.setName(_nameController.text);
    notifier.setAbout(_aboutController.text);
    notifier.setBio(_bioController.text);

    final success = await notifier.submit(widget.profile);
    if (success && mounted) {
      Navigator.of(context).pop(true); // pop with success signal
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show errors via SnackBar
    ref.listen(editProfileNotifierProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // Determine what image to display
    final ImageProvider? imageProvider = state.pickedImage != null
        ? FileImage(state.pickedImage!)
        : (state.uploadedImageUrl != null
            ? NetworkImage(state.uploadedImageUrl!) as ImageProvider
            : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: state.isSubmitting ? null : _submit,
            child: state.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- Avatar ----
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person,
                              size: 56, color: AppColors.primary)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: colorScheme.surface, width: 2),
                      ),
                      child: Icon(Icons.camera_alt,
                          size: 18, color: colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _pickImage,
                child: const Text('Change photo'),
              ),
            ),
            const SizedBox(height: 24),

            // ---- Name ----
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Display name *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // ---- About ----
            TextFormField(
              controller: _aboutController,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'About',
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
                helperText: 'A short status or tagline',
              ),
            ),
            const SizedBox(height: 16),

            // ---- Bio ----
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Bio',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 56),
                  child: Icon(Icons.edit_note),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // ---- Save button ----
            FilledButton(
              onPressed: state.isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
