import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/theme/service_semantics.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceSemanticTheme', () {
    test('maps common service families to ARS semantic colors and icons', () {
      expect(
        ServiceSemanticTheme.resolve('Flat Tire'),
        const ServiceSemantic(
          accentColor: AppTheme.emergencyColor,
          backgroundColor: AppTheme.emergencyBg,
          icon: LucideIcons.disc_3,
        ),
      );

      expect(
        ServiceSemanticTheme.resolve('Brake Pad Replacement'),
        const ServiceSemantic(
          accentColor: AppTheme.warningColor,
          backgroundColor: AppTheme.warningBg,
          icon: LucideIcons.triangle_alert,
        ),
      );

      expect(
        ServiceSemanticTheme.resolve('Engine Oil Change'),
        const ServiceSemantic(
          accentColor: AppTheme.infoColor,
          backgroundColor: AppTheme.infoBg,
          icon: LucideIcons.droplet,
        ),
      );

      expect(
        ServiceSemanticTheme.resolve('Battery Issue'),
        const ServiceSemantic(
          accentColor: AppTheme.successColor,
          backgroundColor: AppTheme.successBg,
          icon: LucideIcons.zap,
        ),
      );
    });

    test(
      'emergency requests use emergency colors without losing service icon',
      () {
        expect(
          ServiceSemanticTheme.resolve('Battery Issue', isEmergency: true),
          const ServiceSemantic(
            accentColor: AppTheme.emergencyColor,
            backgroundColor: AppTheme.emergencyBg,
            icon: LucideIcons.zap,
          ),
        );
      },
    );
  });
}
