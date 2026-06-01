import 'dart:io';
import 'dart:math' as math;

import 'package:arsapplication/core/theme/app_colors.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

double _linearize(int channel) {
  final value = channel / 255;
  return value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color color) {
  final value = color.toARGB32();
  final red = (value >> 16) & 0xff;
  final green = (value >> 8) & 0xff;
  final blue = value & 0xff;
  return 0.2126 * _linearize(red) +
      0.7152 * _linearize(green) +
      0.0722 * _linearize(blue);
}

double _contrast(Color foreground, Color background) {
  final foregroundLuminance = _luminance(foreground);
  final backgroundLuminance = _luminance(background);
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

Color _colorFromHex(String hex) {
  return Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
}

Map<String, Color> _previewVars(String theme) {
  final html = File(
    'docs/design-system/ARS_DESIGN_SYSTEM_PREVIEW.html',
  ).readAsStringSync();
  final match = RegExp(
    'html\\[data-theme="$theme"\\]\\s*\\{(.*?)\\}',
    dotAll: true,
  ).firstMatch(html);

  if (match == null) {
    throw StateError('Could not find $theme theme block in ARS preview.');
  }

  final vars = <String, Color>{};
  final varPattern = RegExp(r'--([a-z0-9-]+):(#(?:[0-9A-Fa-f]{6}));');
  for (final varMatch in varPattern.allMatches(match.group(1)!)) {
    vars[varMatch.group(1)!] = _colorFromHex(varMatch.group(2)!);
  }
  return vars;
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ARS design-system tokens', () {
    test('map light colors to the researched roadside palette', () {
      expect(ArsLightColors.primary, const Color(0xFFF97316));
      expect(ArsLightColors.onPrimary, const Color(0xFF0F172A));
      expect(ArsLightColors.emergency, const Color(0xFFDC2626));
      expect(ArsLightColors.onEmergency, Colors.white);
      expect(ArsLightColors.trust, const Color(0xFF3DB3A9));
      expect(ArsLightColors.info, const Color(0xFF3B82F6));
      expect(ArsLightColors.success, const Color(0xFF16A34A));
    });

    test('match the HTML design-system preview source of truth', () {
      final light = _previewVars('light');
      expect(light['background'], ArsLightColors.background);
      expect(light['surface'], ArsLightColors.surface);
      expect(light['surface-muted'], ArsLightColors.surfaceMuted);
      expect(light['surface-raised'], ArsLightColors.surfaceRaised);
      expect(light['text1'], ArsLightColors.text1);
      expect(light['text2'], ArsLightColors.text2);
      expect(light['text3'], ArsLightColors.text3);
      expect(light['border'], ArsLightColors.border);
      expect(light['border-strong'], ArsLightColors.borderStrong);
      expect(light['primary'], ArsLightColors.primary);
      expect(light['on-primary'], ArsLightColors.onPrimary);
      expect(light['primary-bg'], ArsLightColors.primaryBg);
      expect(light['primary-tx'], ArsLightColors.primaryTx);
      expect(light['emergency'], ArsLightColors.emergency);
      expect(light['on-emergency'], ArsLightColors.onEmergency);
      expect(light['emergency-bg'], ArsLightColors.emergencyBg);
      expect(light['emergency-tx'], ArsLightColors.emergencyTx);
      expect(light['trust'], ArsLightColors.trust);
      expect(light['on-trust'], ArsLightColors.onTrust);
      expect(light['trust-bg'], ArsLightColors.trustBg);
      expect(light['trust-tx'], ArsLightColors.trustTx);
      expect(light['info'], ArsLightColors.info);
      expect(light['on-info'], ArsLightColors.onInfo);
      expect(light['info-bg'], ArsLightColors.infoBg);
      expect(light['info-tx'], ArsLightColors.infoTx);
      expect(light['success'], ArsLightColors.success);
      expect(light['success-bg'], ArsLightColors.successBg);
      expect(light['success-tx'], ArsLightColors.successTx);
      expect(light['warning'], ArsLightColors.warning);
      expect(light['warning-bg'], ArsLightColors.warningBg);
      expect(light['warning-tx'], ArsLightColors.warningTx);

      final dark = _previewVars('dark');
      expect(dark['background'], ArsDarkColors.background);
      expect(dark['surface'], ArsDarkColors.surface);
      expect(dark['surface-muted'], ArsDarkColors.surfaceMuted);
      expect(dark['surface-raised'], ArsDarkColors.surfaceRaised);
      expect(dark['text1'], ArsDarkColors.text1);
      expect(dark['text2'], ArsDarkColors.text2);
      expect(dark['text3'], ArsDarkColors.text3);
      expect(dark['border'], ArsDarkColors.border);
      expect(dark['border-strong'], ArsDarkColors.borderStrong);
      expect(dark['primary'], ArsDarkColors.primary);
      expect(dark['on-primary'], ArsDarkColors.onPrimary);
      expect(dark['primary-bg'], ArsDarkColors.primaryBg);
      expect(dark['primary-tx'], ArsDarkColors.primaryTx);
      expect(dark['emergency'], ArsDarkColors.emergency);
      expect(dark['on-emergency'], ArsDarkColors.onEmergency);
      expect(dark['emergency-bg'], ArsDarkColors.emergencyBg);
      expect(dark['emergency-tx'], ArsDarkColors.emergencyTx);
      expect(dark['trust'], ArsDarkColors.trust);
      expect(dark['on-trust'], ArsDarkColors.onTrust);
      expect(dark['trust-bg'], ArsDarkColors.trustBg);
      expect(dark['trust-tx'], ArsDarkColors.trustTx);
      expect(dark['info'], ArsDarkColors.info);
      expect(dark['on-info'], ArsDarkColors.onInfo);
      expect(dark['info-bg'], ArsDarkColors.infoBg);
      expect(dark['info-tx'], ArsDarkColors.infoTx);
      expect(dark['success'], ArsDarkColors.success);
      expect(dark['success-bg'], ArsDarkColors.successBg);
      expect(dark['success-tx'], ArsDarkColors.successTx);
      expect(dark['warning'], ArsDarkColors.warning);
      expect(dark['warning-bg'], ArsDarkColors.warningBg);
      expect(dark['warning-tx'], ArsDarkColors.warningTx);
    });

    test('use accessible foregrounds for core CTA roles', () {
      expect(
        _contrast(ArsLightColors.onPrimary, ArsLightColors.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(ArsLightColors.onEmergency, ArsLightColors.emergency),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(ArsDarkColors.onPrimary, ArsDarkColors.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(ArsDarkColors.onEmergency, ArsDarkColors.emergency),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('wire Material 3 color roles for light and dark themes', () {
      final lightScheme = AppTheme.lightTheme.colorScheme;
      expect(lightScheme.primary, ArsLightColors.primary);
      expect(lightScheme.onPrimary, ArsLightColors.onPrimary);
      expect(lightScheme.secondary, ArsLightColors.trust);
      expect(lightScheme.tertiary, ArsLightColors.info);
      expect(lightScheme.error, ArsLightColors.emergency);

      final darkScheme = AppTheme.darkTheme.colorScheme;
      expect(darkScheme.primary, ArsDarkColors.primary);
      expect(darkScheme.onPrimary, ArsDarkColors.onPrimary);
      expect(darkScheme.secondary, ArsDarkColors.trust);
      expect(darkScheme.tertiary, ArsDarkColors.info);
      expect(darkScheme.error, ArsDarkColors.emergency);
    });

    testWidgets(
      'CustomButton defaults to orange service CTA with asphalt text',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: CustomButton(text: 'Book service', onPressed: () {}),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        final states = <WidgetState>{};
        expect(
          button.style?.backgroundColor?.resolve(states),
          ArsLightColors.primary,
        );
        expect(
          button.style?.foregroundColor?.resolve(states),
          ArsLightColors.onPrimary,
        );
      },
    );
  });
}
