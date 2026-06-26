import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/design.dart';
import '../router.dart';

/// Branded splash. Shows the Talyer mark, then routes to role selection.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (mounted) context.go(Routes.roleSelect);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.talyer;
    return Scaffold(
      backgroundColor: t.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TalyerMark(size: 96),
            const SizedBox(height: TalyerSpacing.x5),
            Text('Talyer', style: context.tt.displaySmall),
            const SizedBox(height: TalyerSpacing.x2),
            Text('Verified mechanics, on demand.',
                style: TalyerType.bodyMedium.copyWith(color: t.text2)),
          ],
        ),
      ),
    );
  }
}
