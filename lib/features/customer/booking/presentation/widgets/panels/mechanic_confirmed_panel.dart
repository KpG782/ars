/// Mechanic Confirmed Panel
///
/// Shows mechanic details and actions after booking is confirmed.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/models/mechanic.dart';
import '../share_location_sheet.dart';
import '../eta_display.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/payment/payment_details_screen.dart';

class MechanicConfirmedPanel extends StatelessWidget {
  final String? selectedSubService;
  final VoidCallback onResetBooking;
  final Mechanic? mechanic;
  final LatLng customerLocation;

  const MechanicConfirmedPanel({
    super.key,
    required this.selectedSubService,
    required this.onResetBooking,
    this.mechanic,
    required this.customerLocation,
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Compact Status Row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mechanic on the way!',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          selectedSubService ?? 'Service',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Compact ETA Display using CompactETADisplay
              if (mechanic != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mechanic!.name,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSize14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            CompactETADisplay(
                              mechanicLocation: mechanic!.location,
                              customerLocation: customerLocation,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                mechanic: mechanic!,
                                serviceType: selectedSubService ?? 'Service',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.message,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Share Location Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      isDismissible: true,
                      builder: (context) => ShareLocationSheet(
                        latitude: customerLocation.latitude,
                        longitude: customerLocation.longitude,
                        customerName: 'Customer',
                        mechanicName: mechanic?.name ?? 'Mechanic',
                        eta: '5-10 min',
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppTheme.primarySurface,
                  ),
                  icon: const Icon(
                    Icons.share_location,
                    color: AppTheme.primaryDark,
                    size: 18,
                  ),
                  label: const Text(
                    'Share Live Location with Family',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Compact Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onResetBooking,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: AppTheme.red,
                        size: 18,
                      ),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentDetailsScreen(
                              mechanicName: mechanic?.name ?? 'John Mechanic',
                              serviceName: selectedSubService ?? 'Service',
                              location:
                                  '${customerLocation.latitude.toStringAsFixed(4)}, ${customerLocation.longitude.toStringAsFixed(4)}',
                              amount: 500.00,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Proceed to Pay',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
