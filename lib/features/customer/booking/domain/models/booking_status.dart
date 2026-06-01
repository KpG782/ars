/// Domain Model: Booking Status
///
/// Represents the state of a booking flow
library;

enum BookingStatus {
  initial,
  emergency,
  serviceSelection,
  subServiceSelection,
  details,
  searching,
  confirmed,
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.initial:
        return 'Initial';
      case BookingStatus.emergency:
        return 'Emergency Request';
      case BookingStatus.serviceSelection:
        return 'Service Selection';
      case BookingStatus.subServiceSelection:
        return 'Sub-Service Selection';
      case BookingStatus.details:
        return 'Details';
      case BookingStatus.searching:
        return 'Searching for Mechanic';
      case BookingStatus.confirmed:
        return 'Booking Confirmed';
    }
  }

  bool get canGoBack {
    return this != BookingStatus.initial &&
        this != BookingStatus.searching &&
        this != BookingStatus.confirmed;
  }

  bool get isInProgress {
    return this == BookingStatus.searching || this == BookingStatus.confirmed;
  }
}
