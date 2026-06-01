/// Searching Panel
///
/// Shows loading state while searching for nearby mechanics.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class SearchingPanel extends StatelessWidget {
  final String? selectedSubService;
  final VoidCallback onCancel;

  const SearchingPanel({
    super.key,
    required this.selectedSubService,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Searching for nearby mechanics...',
                style: TextStyle(
                  fontSize: AppTheme.fontSize18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Service: ${selectedSubService ?? 'Selected Service'}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close, color: AppTheme.red, size: 20),
                  label: const Text(
                    'Cancel Search',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
