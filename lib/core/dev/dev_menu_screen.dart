import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart' show UserTypeSelectionScreen;
import '../theme/app_theme.dart';
import 'dev_samples.dart';

// Onboarding
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/loading_screen.dart';

// Customer
import '../../features/customer/auth/presentation/screens/user_login_screen.dart';
import '../../features/customer/auth/presentation/screens/user_signup_screen.dart';
import '../../features/customer/auth/presentation/screens/user_email_verification_screen.dart';
import '../../features/customer/dashboard/presentation/screens/user_dashboard.dart';
import '../../features/customer/booking/presentation/screens/booking_screen.dart';
import '../../features/customer/booking/presentation/screens/location_selection_screen.dart';
import '../../features/customer/booking/presentation/screens/ai_chat_screen.dart';
import '../../features/customer/booking/presentation/screens/chat/chat_screen.dart';
import '../../features/customer/booking/presentation/screens/payment/payment_details_screen.dart';
import '../../features/customer/booking/presentation/screens/payment/payment_screen.dart';
import '../../features/customer/booking/presentation/screens/payment/payment_success_screen.dart';
import '../../features/customer/history/presentation/screens/booking_history_screen.dart';
import '../../features/customer/vehicles/presentation/screens/my_vehicles_screen.dart';
import '../../features/customer/saved_places/presentation/screens/saved_places_screen.dart';
import '../../features/customer/payment/presentation/screens/payment_methods_screen.dart';
import '../../features/customer/support/presentation/screens/support_screen.dart';
import '../../features/customer/feedback/presentation/screens/feedback_screen.dart';

// Mechanic
import '../../features/mechanic/auth/presentation/screens/mechanic_splash_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_auth_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_mobile_number_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_basic_info_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_professional_details_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_verification_status_screen.dart';
import '../../features/mechanic/dashboard/presentation/screens/mechanic_dashboard.dart';
import '../../features/mechanic/dashboard/presentation/screens/profile_settings_screen.dart';
import '../../features/mechanic/dashboard/presentation/screens/completion_summary_screen.dart';
import '../../features/mechanic/dashboard/presentation/screens/payment_confirmation_screen.dart';
import '../../features/mechanic/earnings/presentation/screens/earnings_screen.dart';
import '../../features/mechanic/services/presentation/screens/service_history_screen.dart';
import '../../features/mechanic/services/presentation/screens/booking_request.dart';
import '../../features/mechanic/chat/presentation/screens/mechanic_chat_screen.dart';

/// A single entry in the dev catalog.
class _Entry {
  final String label;
  final Widget Function() build;
  const _Entry(this.label, this.build);
}

class _Section {
  final String title;
  final List<_Entry> entries;
  const _Section(this.title, this.entries);
}

/// Debug-only screen catalog: open any screen directly, no auth/backend needed.
/// Wired in only when `kDebugMode` is true (see app_router.dart).
class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  List<_Section> get _sections => [
    _Section('Onboarding', [
      _Entry('Splash', () => const SplashScreen()),
      _Entry('Onboarding', () => const OnboardingScreen()),
      _Entry('Loading', () => const LoadingScreen()),
      _Entry('Role select (Who are you?)', () => const UserTypeSelectionScreen()),
    ]),
    _Section('Customer', [
      _Entry('Login', () => const UserLoginScreen()),
      _Entry('Sign up', () => const UserSignUpScreen()),
      _Entry('Email verification', () => const UserEmailVerificationScreen()),
      _Entry('Dashboard (home)', () => const UserDashboard()),
      _Entry('Booking map', () => const BookingScreen()),
      _Entry('Location selection', () => const LocationSelectionScreen()),
      _Entry('AI diagnostic chat', () => const AiChatScreen(sessionId: 'dev-session')),
      _Entry('Chat with mechanic', () => ChatScreen(
            mechanic: DevSamples.mechanic(),
            serviceType: 'Brake Repair',
          )),
      _Entry('Payment details', () => const PaymentDetailsScreen(
            mechanicName: 'Dev Mechanic',
            serviceName: 'Brake Repair',
            location: 'Makati City',
            amount: 1500,
          )),
      _Entry('Payment', () => const PaymentScreen(
            mechanicName: 'Dev Mechanic',
            serviceName: 'Brake Repair',
            location: 'Makati City',
            amount: 1500,
            notes: 'Front brake pads',
            tipAmount: 0,
            discount: 0,
            subtotal: 1400,
            serviceFee: 100,
          )),
      _Entry('Payment success', () => const PaymentSuccessScreen(
            mechanicName: 'Dev Mechanic',
            serviceName: 'Brake Repair',
            amount: 1500,
            paymentMethod: 'GCash',
          )),
      _Entry('Booking history', () => const BookingHistoryScreen()),
      _Entry('My vehicles', () => const MyVehiclesScreen()),
      _Entry('Saved places', () => const SavedPlacesScreen()),
      _Entry('Payment methods', () => const PaymentMethodsScreen()),
      _Entry('Support', () => const SupportScreen()),
      _Entry('Feedback', () => const FeedbackScreen()),
    ]),
    _Section('Mechanic', [
      _Entry('Mechanic splash', () => const MechanicSplashScreen()),
      _Entry('Mechanic auth', () => const MechanicAuthScreen()),
      _Entry('Mobile number', () => const MechanicMobileNumberScreen()),
      _Entry('Basic info', () => const MechanicBasicInfoScreen(phoneNumber: '')),
      _Entry('Professional details', () => const MechanicProfessionalDetailsScreen(
            phoneNumber: '',
            firstName: '',
            lastName: '',
            username: '',
            email: '',
          )),
      _Entry('Verification status', () => const MechanicVerificationStatusScreen()),
      _Entry('Dashboard', () => const MechanicDashboard()),
      _Entry('Profile settings', () => const ProfileSettingsScreen()),
      _Entry('Earnings', () => const EarningsScreen()),
      _Entry('Service history', () => const ServiceHistoryScreen()),
      _Entry('Incoming booking map', () => const BookingRequestMapScreen()),
      _Entry('Chat with customer', () => MechanicChatScreen(
            serviceRequest: DevSamples.serviceRequest(),
          )),
      _Entry('Completion summary', () => CompletionSummaryScreen(
            serviceRequest: DevSamples.serviceRequest(),
            workDuration: const Duration(minutes: 45),
            workPhotos: const [],
            mechanicNotes: 'Replaced front brake pads.',
            onConfirm: () {},
          )),
      _Entry('Payment confirmation', () => MechanicPaymentConfirmationScreen(
            serviceRequest: DevSamples.serviceRequest(),
            onConfirm: () {},
          )),
    ]),
  ];

  void _open(BuildContext context, _Entry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => entry.build()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Menu — all screens'),
        backgroundColor: scheme.surface,
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Real app'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primaryColor.withValues(alpha: 0.10),
            padding: const EdgeInsets.all(12),
            child: Text(
              'Debug-only catalog. Tap a screen to preview its UI (auth bypassed; '
              'data-backed screens may show empty/sample state). Back returns here.',
              style: TextStyle(fontSize: AppTheme.fontSize12, color: scheme.onSurfaceVariant),
            ),
          ),
          for (final section in _sections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                section.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: AppTheme.fontSize12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            for (final entry in section.entries)
              ListTile(
                dense: true,
                leading: const Icon(Icons.chevron_right),
                title: Text(entry.label),
                onTap: () => _open(context, entry),
              ),
          ],
        ],
      ),
    );
  }
}
