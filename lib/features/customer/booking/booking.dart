/// Customer Booking Module Barrel Export
///
/// Provides clean imports for customer booking following Clean Architecture.
/// Usage example:
///   import 'package:arsapplication/features/customer/booking/booking.dart';
library;

// Domain Layer Exports
export 'domain/models/mechanic.dart';
export 'domain/models/mechanic_shop.dart';
export 'domain/models/booking_status.dart';
export 'domain/repositories/mechanic_repository.dart';
export 'domain/repositories/shop_repository.dart';

// Data Layer Exports
export 'data/repositories/osrm_mechanic_repository.dart';
export 'data/repositories/mock_shop_repository.dart';

// Controller Exports
export 'presentation/controllers/booking_controller.dart';

// Presentation Layer Exports - Screens
export 'presentation/screens/booking.dart'; // Legacy - kept for compatibility
export 'presentation/screens/booking_screen.dart'
    hide BookingScreen; // New modular version (use ModularBookingScreen)
export 'presentation/screens/location_selection_screen.dart';
export 'presentation/screens/chat/chat_screen.dart';
export 'presentation/screens/payment/payment_details_screen.dart';
export 'presentation/screens/payment/payment_screen.dart';
export 'presentation/screens/payment/payment_success_screen.dart';

// Presentation Layer Exports - Widgets
export 'presentation/widgets/booking_bottom_panels.dart'; // Legacy
export 'presentation/widgets/booking_bottom_panels_refactored.dart'; // Modular version
export 'presentation/widgets/booking_drawer.dart';
export 'presentation/widgets/booking_enums.dart';
export 'presentation/widgets/booking_status_panels.dart'
    hide SearchingPanel, BookingDetailsPanel; // Hide conflicting exports
export 'presentation/widgets/booking_map_widget.dart';
export 'presentation/widgets/booking_search_bar.dart';
export 'presentation/widgets/booking_dialogs.dart';
export 'presentation/widgets/mechanic_details_sheet.dart';
export 'presentation/widgets/shop_details_sheet.dart';
export 'presentation/widgets/eta_display.dart';
export 'presentation/widgets/service_selection.dart';
export 'presentation/widgets/share_location_sheet.dart';
export 'presentation/widgets/sub_service_dialogs.dart';

// Panel Widgets (Modular) - hide conflicting names
export 'presentation/widgets/panels/panels.dart'
    hide MechanicConfirmedPanel, SearchingPanel;
