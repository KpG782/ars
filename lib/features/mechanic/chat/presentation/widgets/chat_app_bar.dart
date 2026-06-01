import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String customerName;
  final VoidCallback onVoiceCall;
  final VoidCallback onBack;

  const ChatAppBar({
    super.key,
    required this.customerName,
    required this.onVoiceCall,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack,
      ),
      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(LucideIcons.user, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSize17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: AppTheme.fontSize13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.white),
          onPressed: onVoiceCall,
          tooltip: 'Call',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
