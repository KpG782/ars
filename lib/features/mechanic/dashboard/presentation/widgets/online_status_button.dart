/// Online Status Toggle Button
///
/// Floating action button for toggling mechanic online/offline status.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/mechanic_status.dart';

class OnlineStatusButton extends StatelessWidget {
  final MechanicStatus status;
  final bool isOnline;
  final bool isLoading;
  final VoidCallback? onToggle;

  const OnlineStatusButton({
    super.key,
    required this.status,
    required this.isOnline,
    this.isLoading = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final canToggle =
        status != MechanicStatus.working && status != MechanicStatus.enRoute;

    return GestureDetector(
      onTap: isLoading ? null : onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOnline
                ? [AppTheme.successColor, AppTheme.successTx]
                : [AppTheme.grey600, AppTheme.grey700],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (isOnline ? AppTheme.successColor : AppTheme.grey)
                  .withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 20,
              ),
            const SizedBox(width: 10),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTheme.fontSize15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!canToggle && isOnline) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status == MechanicStatus.enRoute ? 'En Route' : 'Working',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSize11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
