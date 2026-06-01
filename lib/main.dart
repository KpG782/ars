import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Allow app startup even if .env is missing in fresh setups.
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await NotificationService().initialize();
  runApp(const ProviderScope(child: ArsApp()));
}

class ArsApp extends ConsumerWidget {
  const ArsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'ARS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  String? _selectedType;

  void _onCardTap(String type) {
    setState(() {
      _selectedType = type;
    });
  }

  Future<void> _continue() async {
    if (_selectedType == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', _selectedType!);

    if (!mounted) return;

    if (_selectedType == 'mechanic') {
      await prefs.setBool('has_seen_onboarding', true);
      if (!mounted) return;
      context.go(AppRoutes.mechanicSplash);
    } else {
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      if (hasSeenOnboarding) {
        context.go(AppRoutes.login);
      } else {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Text(
                  'Who are you?',
                  style: AppTheme.figtreeExtraBold.copyWith(
                    fontSize: AppTheme.fontSize28,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your role to get started with\nthe right experience.',
                  style: AppTheme.figtreeRegular.copyWith(
                    fontSize: AppTheme.fontSize15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _UserTypeCard(
                  icon: LucideIcons.car,
                  title: 'Find a Mechanic',
                  subtitle:
                      'I have a vehicle that needs repair or maintenance.',
                  isSelected: _selectedType == 'user',
                  onTap: () => _onCardTap('user'),
                ),
                const SizedBox(height: 16),
                _UserTypeCard(
                  icon: LucideIcons.wrench,
                  title: 'Join as Mechanic',
                  subtitle: 'I am a professional looking for repair jobs.',
                  isSelected: _selectedType == 'mechanic',
                  onTap: () => _onCardTap('mechanic'),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _selectedType != null ? _continue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.onPrimaryColor,
                      disabledBackgroundColor: AppTheme.primaryColor.withAlpha(
                        100,
                      ),
                      disabledForegroundColor: AppTheme.onPrimaryColor
                          .withAlpha(140),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text('Continue', style: AppTheme.buttonMedium),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTheme.figtreeRegular.copyWith(
                        fontSize: AppTheme.fontSize14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: Text(
                        'Log in',
                        style: AppTheme.figtreeSemiBold.copyWith(
                          fontSize: AppTheme.fontSize14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withAlpha(30)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.figtreeSemiBold.copyWith(
                      fontSize: AppTheme.fontSize16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.figtreeRegular.copyWith(
                      fontSize: AppTheme.fontSize13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
