import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';

class CallDialog {
  static void showVoiceCall(BuildContext context, String customerName) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(LucideIcons.phone, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Voice Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.trustBg,
              child: Icon(
                LucideIcons.user,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Calling $customerName...',
              style: const TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Connecting...', style: TextStyle(color: AppTheme.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastHelper.showInfo(context, 'Call ended');
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.call_end, size: 20),
                SizedBox(width: 8),
                Text('End Call'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
