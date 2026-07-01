import 'package:chatify/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  const Avatar({super.key, required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(imageUrl!));
    }
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return CircleAvatar(
      backgroundColor: AppColors.primaryLight,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
