import 'package:go_router/go_router.dart';

import '../features/customer/mechanics/presentation/find_mechanic_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/gallery_screen.dart';

abstract final class Routes {
  static const splash = '/';
  static const roleSelect = '/role';
  static const findMechanic = '/find';
  static const gallery = '/gallery';
}

/// Single router for the whole app. Customer & mechanic live as subtrees here
/// (never a split app). A `redirect` reading the session provider will guard
/// auth + role once Phase-1 auth lands.
final router = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: Routes.roleSelect, builder: (_, __) => const RoleSelectScreen()),
    GoRoute(
        path: Routes.findMechanic,
        builder: (_, __) => const FindMechanicScreen()),
    GoRoute(path: Routes.gallery, builder: (_, __) => const GalleryScreen()),
  ],
);
