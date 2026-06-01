/// Initial Bottom Panel
///
/// Shows the initial service selection button and emergency SOS option.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import '../booking_enums.dart';

class InitialBottomPanel extends StatelessWidget {
  final String? selectedService;
  final String? selectedSubService;
  final Function(String) onServiceSelected;
  final Function(BookingStatus) onBookingStatusChanged;
  final VoidCallback? onEmergencyPressed;

  const InitialBottomPanel({
    super.key,
    required this.selectedService,
    required this.selectedSubService,
    required this.onServiceSelected,
    required this.onBookingStatusChanged,
    this.onEmergencyPressed,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = selectedService ?? 'Choose Service';
    if (selectedSubService != null) {
      displayText = '$selectedService: $selectedSubService';
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.15,
      maxChildSize: 0.3,
      snap: true,
      snapSizes: const [0.15, 0.18],
      builder: (context, scrollController) => Container(
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
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 30.0),
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            InkWell(
              onTap: () =>
                  onBookingStatusChanged(BookingStatus.serviceSelection),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.grey200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.grey400),
                      ),
                      child: Icon(
                        selectedService != null ? Icons.check : Icons.add,
                        color: selectedService != null
                            ? AppTheme.primaryColor
                            : AppTheme.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize18,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.grey,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (onEmergencyPressed != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onEmergencyPressed,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.red,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Emergency SOS',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.red,
                        ),
                      ),
                    ],
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
