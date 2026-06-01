/// Booking Details Panel
///
/// Shows booking confirmation details before searching.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import '../booking_enums.dart';

class BookingDetailsPanel extends StatelessWidget {
  final String? selectedSubService;
  final Function(BookingStatus) onBookingStatusChanged;

  const BookingDetailsPanel({
    super.key,
    required this.selectedSubService,
    required this.onBookingStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.18,
      maxChildSize: 0.4,
      snap: true,
      snapSizes: const [0.18, 0.25],
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
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 20.0),
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: AppTheme.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Service: ${selectedSubService ?? 'Selected Service'}',
              style: const TextStyle(fontSize: AppTheme.fontSize16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        onBookingStatusChanged(BookingStatus.initial),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    onPressed: () =>
                        onBookingStatusChanged(BookingStatus.searching),
                    child: const Text('Confirm Booking'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
