import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/customer/auth/presentation/screens/user_email_verification_screen.dart';
import '../../features/customer/auth/presentation/screens/user_login_screen.dart';
import '../../features/customer/auth/presentation/screens/user_signup_screen.dart';
import '../../features/customer/booking/presentation/screens/booking_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_auth_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_basic_info_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_professional_details_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_splash_screen.dart';
import '../../features/mechanic/auth/presentation/screens/mechanic_verification_status_screen.dart';
import '../../features/mechanic/dashboard/presentation/screens/mechanic_dashboard.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../../main.dart' show UserTypeSelectionScreen;
import '../dev/dev_menu_screen.dart';
import '../providers/core_providers.dart';

/// Global navigator key used for navigation outside the widget tree
/// (e.g., from notification handlers).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const splash = '/';
  static const userType = '/user-type';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const verifyEmail = '/verify-email';
  static const customerBooking = '/customer/booking';
  static const mechanicSplash = '/mechanic/splash';
  static const mechanicAuth = '/mechanic/auth';
  static const mechanicBasicInfo = '/mechanic/onboarding/basic-info';
  static const mechanicProfessional = '/mechanic/onboarding/professional';
  static const mechanicVerification = '/mechanic/verification';
  static const mechanicDashboard = '/mechanic/dashboard';
  static const dev = '/dev';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    // In debug builds, boot straight into the Dev Menu so every screen can be
    // browsed without a backend. Release builds start at the splash flow.
    initialLocation: kDebugMode ? AppRoutes.dev : AppRoutes.splash,
    redirect: (context, state) {
      // Debug builds: skip the auth guard entirely so protected screens
      // (booking, mechanic dashboard, ...) open without logging in.
      if (kDebugMode) return null;

      final isLoggedIn = authState.value != null;
      final isPublicRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.userType ||
          state.matchedLocation == AppRoutes.mechanicSplash ||
          state.matchedLocation == AppRoutes.mechanicAuth ||
          state.matchedLocation == AppRoutes.mechanicBasicInfo ||
          state.matchedLocation == AppRoutes.mechanicProfessional ||
          state.matchedLocation == AppRoutes.mechanicVerification;

      if (!isLoggedIn &&
          !isPublicRoute &&
          state.matchedLocation != AppRoutes.splash) {
        return AppRoutes.userType;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.userType,
        builder: (context, state) => const UserTypeSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const UserLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const UserSignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) => const UserEmailVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerBooking,
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicSplash,
        builder: (context, state) => const MechanicSplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicAuth,
        builder: (context, state) => const MechanicAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicBasicInfo,
        builder: (context, state) =>
            const MechanicBasicInfoScreen(phoneNumber: ''),
      ),
      GoRoute(
        path: AppRoutes.mechanicProfessional,
        builder: (context, state) => const MechanicProfessionalDetailsScreen(
          phoneNumber: '',
          email: '',
          firstName: '',
          lastName: '',
          username: '',
        ),
      ),
      GoRoute(
        path: AppRoutes.mechanicVerification,
        builder: (context, state) => const MechanicVerificationStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.mechanicDashboard,
        builder: (context, state) => const MechanicDashboard(),
      ),
      GoRoute(
        path: AppRoutes.dev,
        builder: (context, state) => const DevMenuScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route not found: ${state.uri}'))),
  );
});
