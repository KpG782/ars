import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'attachment_option.dart';

class AttachmentMenu extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const AttachmentMenu({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AttachmentOption(
            icon: Icons.photo_library,
            label: 'Gallery',
            color: AppTheme.primaryColor,
            onTap: onGalleryTap,
          ),
          AttachmentOption(
            icon: Icons.camera_alt,
            label: 'Camera',
            color: AppTheme.blue,
            onTap: onCameraTap,
          ),
        ],
      ),
    );
  }
}
