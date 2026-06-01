/// Mechanic Dashboard Dialogs
///
/// Reusable confirmation dialogs for mechanic dashboard actions.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/mechanic_status.dart';

class MechanicDashboardDialogs {
  /// Show go offline confirmation dialog
  static Future<bool> showGoOfflineConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: AppTheme.warningColor),
            SizedBox(width: 12),
            Text('Go Offline?'),
          ],
        ),
        content: const Text(
          'You will stop receiving service requests. '
          'Are you sure you want to go offline?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.grey),
            child: const Text('Go Offline'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show go online confirmation dialog
  static Future<bool> showGoOnlineConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.wifi, color: AppTheme.successColor),
            SizedBox(width: 12),
            Text('Go Online?'),
          ],
        ),
        content: const Text(
          'You will start receiving service requests from nearby customers. '
          'Are you ready to accept jobs?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Go Online'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show cannot go offline dialog
  static Future<void> showCannotGoOfflineDialog(
    BuildContext context,
    MechanicStatus status,
  ) async {
    final statusText = status == MechanicStatus.enRoute
        ? 'traveling to a customer'
        : 'working on a service';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.warningColor),
            SizedBox(width: 12),
            Text('Cannot Go Offline'),
          ],
        ),
        content: Text(
          'You are currently $statusText. '
          'Please complete your current job before going offline.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  /// Show service completed success dialog
  static Future<void> showServiceCompletedDialog(
    BuildContext context, {
    required double earnings,
    String? customerName,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Service Completed!',
              style: TextStyle(
                fontSize: AppTheme.fontSize22,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            if (customerName != null)
              Text(
                'Great job helping $customerName',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey600,
                ),
              ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Earnings',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize13,
                      color: AppTheme.warningTx,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${earnings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: AppTheme.fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show logout confirmation dialog
  static Future<bool> showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.red),
            SizedBox(width: 12),
            Text('Logout?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? '
          'You will stop receiving service requests.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show arrive confirmation dialog
  static Future<bool> showArriveConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: AppTheme.infoColor),
            SizedBox(width: 12),
            Text('Confirm Arrival'),
          ],
        ),
        content: const Text(
          'Are you at the customer\'s location? '
          'This will notify the customer that you have arrived.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.infoColor,
            ),
            child: const Text('Yes, I\'ve Arrived'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
