/// Dashboard Module Barrel Export
///
/// Provides clean imports for the dashboard feature following Clean Architecture.
/// Usage example:
///   import 'package:arsapplication/features/mechanic/dashboard/dashboard.dart';
library;

// Domain Layer Exports
export 'domain/models/service_request.dart';
export 'domain/models/mechanic_status.dart';
export 'domain/repositories/dashboard_repository.dart';

// Data Layer Exports
export 'data/repositories/firebase_service_request_repository.dart';
export 'data/repositories/firebase_mechanic_repository.dart';

// Presentation Layer Exports
// Screens
export 'presentation/screens/mechanic_dashboard.dart'; // Original (to be deprecated)
export 'presentation/screens/mechanic_dashboard_screen.dart'; // Refactored modular version
export 'presentation/screens/completion_summary_screen.dart';
export 'presentation/screens/payment_confirmation_screen.dart';
export 'presentation/screens/profile_settings_screen.dart';

// Controllers
export 'presentation/controllers/mechanic_dashboard_controller.dart';

// Widgets
export 'presentation/widgets/mechanic_bottom_panels.dart';
export 'presentation/widgets/mechanic_drawer.dart';
export 'presentation/widgets/mechanic_enums.dart';
export 'presentation/widgets/service_request_card.dart';
export 'presentation/widgets/mechanic_map_widget.dart';
export 'presentation/widgets/mechanic_dashboard_top_bar.dart';
export 'presentation/widgets/mechanic_dashboard_dialogs.dart';
export 'presentation/widgets/online_status_button.dart';
export 'presentation/widgets/nearby_requests_panel.dart';
export 'presentation/widgets/active_job_panel.dart';
export 'presentation/widgets/service_request_details_sheet.dart';
