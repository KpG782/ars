/// Booking Dialogs - Confirmation dialogs for booking operations
///
/// Reusable dialogs for cancel confirmation, exit warnings, etc.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'booking_enums.dart';

/// Helper class for showing booking-related dialogs
class BookingDialogs {
  /// Show cancel booking confirmation dialog
  static Future<bool> showCancelConfirmation(
    BuildContext context, {
    required BookingStatus bookingStatus,
  }) async {
    String title = 'Cancel Booking?';
    String message = 'Are you sure you want to cancel this booking?';
    String confirmText = 'Yes, Cancel';

    if (bookingStatus == BookingStatus.confirmed) {
      title = 'Cancel Active Service?';
      message =
          'A mechanic is on the way to your location. Canceling now may result in a cancellation fee. Do you want to continue?';
      confirmText = 'Cancel Service';
    } else if (bookingStatus == BookingStatus.searching) {
      message =
          'We are currently finding a mechanic for you. Do you want to cancel the search?';
    } else if (bookingStatus == BookingStatus.serviceSelection ||
        bookingStatus == BookingStatus.subServiceSelection) {
      message = 'Do you want to cancel and start over?';
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: AppTheme.fontSize15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  /// Show exit confirmation dialog
  static Future<bool> showExitConfirmation(BuildContext context) async {
    final bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.exit_to_app, color: AppTheme.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'Leave Booking?',
                style: TextStyle(
                  fontSize: AppTheme.fontSize18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'You have an active booking in progress. Leaving this screen will not cancel your booking. Do you want to continue?',
            style: TextStyle(fontSize: AppTheme.fontSize15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Stay Here',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    return shouldPop ?? false;
  }

  /// Show logout confirmation dialog
  static Future<bool> showLogoutConfirmation(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: AppTheme.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: AppTheme.fontSize18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: AppTheme.fontSize15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }
}
