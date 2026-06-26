import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/role_select_screen.dart';
import 'screens/gallery_screen.dart';

abstract final class Routes {
  static const splash = '/';
  static const roleSelect = '/role';
  static const gallery = '/gallery';
}

final router = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: Routes.roleSelect, builder: (_, __) => const RoleSelectScreen()),
    GoRoute(path: Routes.gallery, builder: (_, __) => const GalleryScreen()),
  ],
);
