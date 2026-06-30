import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _bioController = TextEditingController();
  final _nameFocus = FocusNode();

  int _currentStep = 0;
  static const int _totalSteps = 3;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _aboutController.dispose();
    _bioController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null && mounted) {
      ref
          .read(createProfileNotifierProvider.notifier)
          .setPickedImage(File(picked.path));
    }
  }

  Future<void> _submit() async {
    // Validate name before submitting
    final name = _nameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please go back and enter your display name (at least 2 characters)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final userId = ref.read(authStateProvider).valueOrNull?.id;
    if (userId == null) return;

    // Capture router before async gap
    final router = GoRouter.of(context);

    final notifier = ref.read(createProfileNotifierProvider.notifier);

    // Push the latest text values into the notifier synchronously
    // before calling submit so the state is fully up to date
    notifier.setName(name);
    notifier.setAbout(_aboutController.text.trim());
    notifier.setBio(_bioController.text.trim());

    final success = await notifier.submit(userId);

    if (success && mounted) {
      // Invalidate the profileExists cache so the router
      // redirect won't send us back here on next evaluation
      ref.invalidate(profileExistsProvider(userId));
      router.go(RouteNames.home);
    }
  }

  bool _canProceedStep2() => _nameController.text.trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createProfileNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen(createProfileNotifierProvider, (prev, next) {
      if (next.errorMessage != null && prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return PopScope(
      // Prevent back navigation — user must complete or is forced here
      canPop: _currentStep > 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) _prevPage();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set up your profile'),
          automaticallyImplyLeading: false,
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevPage,
                )
              : null,
        ),
        body: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(_totalSteps, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _currentStep
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                  );
                }),
              ),
            ),
            Text(
              'Step ${_currentStep + 1} of $_totalSteps',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _Step1ImagePicker(
                    pickedImage: state.pickedImage,
                    onPickImage: _pickImage,
                    onNext: _nextPage,
                  ),
                  _Step2NameAbout(
                    nameController: _nameController,
                    aboutController: _aboutController,
                    nameFocus: _nameFocus,
                    onNext: _nextPage,
                    canProceed: _canProceedStep2,
                  ),
                  _Step3Bio(
                    bioController: _bioController,
                    isSubmitting: state.isSubmitting,
                    onSubmit: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Profile image
// ---------------------------------------------------------------------------

class _Step1ImagePicker extends StatelessWidget {
  final File? pickedImage;
  final VoidCallback onPickImage;
  final VoidCallback onNext;

  const _Step1ImagePicker({
    required this.pickedImage,
    required this.onPickImage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Add a profile photo',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Help your friends recognise you',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: onPickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 72,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: pickedImage != null
                      ? FileImage(pickedImage!) as ImageProvider
                      : null,
                  child: pickedImage == null
                      ? const Icon(Icons.person,
                          size: 72, color: AppColors.primary)
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: Icon(Icons.camera_alt,
                      size: 20, color: colorScheme.onPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onPickImage,
            child: const Text('Choose from gallery'),
          ),
          const SizedBox(height: 40),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (pickedImage != null)
                FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  child: const Text('Continue'),
                ),
              OutlinedButton(
                onPressed: onNext,
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                child: Text(
                    pickedImage != null ? 'Continue without photo' : 'Skip for now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Name + About
// ---------------------------------------------------------------------------

class _Step2NameAbout extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController aboutController;
  final FocusNode nameFocus;
  final VoidCallback onNext;
  final bool Function() canProceed;

  const _Step2NameAbout({
    required this.nameController,
    required this.aboutController,
    required this.nameFocus,
    required this.onNext,
    required this.canProceed,
  });

  @override
  State<_Step2NameAbout> createState() => _Step2NameAboutState();
}

class _Step2NameAboutState extends State<_Step2NameAbout> {
  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'What\'s your name?',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how you\'ll appear to others',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: widget.nameController,
            focusNode: widget.nameFocus,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Display name *',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
              helperText: 'At least 2 characters',
            ),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: widget.aboutController,
            maxLength: 80,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'About (optional)',
              prefixIcon: Icon(Icons.info_outline),
              border: OutlineInputBorder(),
              helperText: 'A short status or tagline',
            ),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: widget.canProceed() ? widget.onNext : null,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52)),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3 — Bio
// ---------------------------------------------------------------------------

class _Step3Bio extends StatelessWidget {
  final TextEditingController bioController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _Step3Bio({
    required this.bioController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tell people about yourself',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional — you can always add this later',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),

          TextFormField(
            controller: bioController,
            maxLines: 5,
            maxLength: 300,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Bio',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 64),
                child: Icon(Icons.edit_note),
              ),
              border: OutlineInputBorder(),
              helperText: 'Share a little more about yourself',
            ),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52)),
            child: isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
