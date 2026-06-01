import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'attachment_menu.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isAttachmentMenuOpen;
  final VoidCallback onToggleAttachmentMenu;
  final VoidCallback onSend;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onTextFieldTap;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.isAttachmentMenuOpen,
    required this.onToggleAttachmentMenu,
    required this.onSend,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onTextFieldTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAttachmentMenuOpen)
            AttachmentMenu(
              onGalleryTap: onGalleryTap,
              onCameraTap: onCameraTap,
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isAttachmentMenuOpen ? Icons.close : Icons.add_circle_outline,
                  color: AppTheme.primaryColor,
                ),
                onPressed: onToggleAttachmentMenu,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: const TextStyle(
                      fontSize: AppTheme.fontSize16,
                      color: AppTheme.grey500,
                      fontWeight: FontWeight.w400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.grey100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                  onTap: onTextFieldTap,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
