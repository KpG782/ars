/// Booking Bottom Panels - Refactored
///
/// Main container that switches between different booking panels.
/// Uses modular panel components for maintainability.
library;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'booking_enums.dart';
import '../../domain/models/mechanic.dart';
import 'panels/panels.dart';

class BookingBottomPanelsRefactored extends StatelessWidget {
  final BookingStatus bookingStatus;
  final String? selectedService;
  final String? selectedSubService;
  final Function(String) onServiceSelected;
  final Function(String) onSubServiceSelected;
  final Function(BookingStatus) onBookingStatusChanged;
  final VoidCallback onResetBooking;
  final VoidCallback? onEmergencyPressed;
  final Mechanic? mechanic;
  final LatLng customerLocation;

  const BookingBottomPanelsRefactored({
    super.key,
    required this.bookingStatus,
    required this.selectedService,
    required this.selectedSubService,
    required this.onServiceSelected,
    required this.onSubServiceSelected,
    required this.onBookingStatusChanged,
    required this.onResetBooking,
    this.onEmergencyPressed,
    this.mechanic,
    required this.customerLocation,
  });

  @override
  Widget build(BuildContext context) {
    switch (bookingStatus) {
      case BookingStatus.emergency:
        return EmergencyPanel(
          onEmergencyServiceSelected: (service) {
            onSubServiceSelected(service);
            onBookingStatusChanged(BookingStatus.searching);
          },
          onCancel: onResetBooking,
        );

      case BookingStatus.initial:
        return InitialBottomPanel(
          selectedService: selectedService,
          selectedSubService: selectedSubService,
          onServiceSelected: (service) {
            onServiceSelected(service);
            _handleServiceSelection(service);
          },
          onBookingStatusChanged: onBookingStatusChanged,
          onEmergencyPressed: onEmergencyPressed,
        );

      case BookingStatus.serviceSelection:
        return ServiceSelectionPanel(
          selectedService: selectedService,
          onServiceSelected: (service) {
            onServiceSelected(service);
            _handleServiceSelection(service);
          },
          onBack: () => onBookingStatusChanged(BookingStatus.initial),
        );

      case BookingStatus.subServiceSelection:
        return SubServiceSelectionPanel(
          selectedService: selectedService!,
          onSubServiceSelected: (subService) {
            onSubServiceSelected(subService);
            onBookingStatusChanged(BookingStatus.searching);
          },
          onBack: () => onBookingStatusChanged(BookingStatus.serviceSelection),
        );

      case BookingStatus.details:
        return BookingDetailsPanel(
          selectedSubService: selectedSubService,
          onBookingStatusChanged: onBookingStatusChanged,
        );

      case BookingStatus.searching:
        return SearchingPanel(
          selectedSubService: selectedSubService,
          onCancel: onResetBooking,
        );

      case BookingStatus.confirmed:
        return MechanicConfirmedPanel(
          selectedSubService: selectedSubService,
          onResetBooking: onResetBooking,
          mechanic: mechanic,
          customerLocation: customerLocation,
        );
    }
  }

  void _handleServiceSelection(String service) {
    // Check if service requires sub-service selection
    const servicesWithSubOptions = [
      'Tire Problem',
      'Brake Problem',
      'Engine Problems',
      'Other Car Problems',
    ];
    if (servicesWithSubOptions.contains(service)) {
      onBookingStatusChanged(BookingStatus.subServiceSelection);
    } else {
      onBookingStatusChanged(BookingStatus.searching);
    }
  }
}
