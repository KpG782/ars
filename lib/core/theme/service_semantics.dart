import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'app_theme.dart';

class ServiceSemantic {
  final Color accentColor;
  final Color backgroundColor;
  final IconData icon;

  const ServiceSemantic({
    required this.accentColor,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    return other is ServiceSemantic &&
        other.accentColor == accentColor &&
        other.backgroundColor == backgroundColor &&
        other.icon == icon;
  }

  @override
  int get hashCode => Object.hash(accentColor, backgroundColor, icon);
}

class ServiceSemanticTheme {
  const ServiceSemanticTheme._();

  static ServiceSemantic resolve(
    String serviceType, {
    bool isEmergency = false,
  }) {
    final type = serviceType.toLowerCase();
    final colors = isEmergency
        ? (AppTheme.emergencyColor, AppTheme.emergencyBg)
        : _colorsFor(type);

    return ServiceSemantic(
      accentColor: colors.$1,
      backgroundColor: colors.$2,
      icon: _iconFor(type),
    );
  }

  static (Color, Color) _colorsFor(String type) {
    if (type.contains('tire')) {
      return (AppTheme.emergencyColor, AppTheme.emergencyBg);
    }
    if (type.contains('brake')) {
      return (AppTheme.warningColor, AppTheme.warningBg);
    }
    if (type.contains('engine') || type.contains('oil')) {
      return (AppTheme.infoColor, AppTheme.infoBg);
    }
    if (type.contains('battery') ||
        type.contains('electrical') ||
        type.contains('ac')) {
      return (AppTheme.successColor, AppTheme.successBg);
    }
    return (AppTheme.primaryColor, AppTheme.primarySurface);
  }

  static IconData _iconFor(String type) {
    if (type.contains('tire')) return LucideIcons.disc_3;
    if (type.contains('brake')) return LucideIcons.triangle_alert;
    if (type.contains('oil')) return LucideIcons.droplet;
    if (type.contains('engine')) return LucideIcons.wrench;
    if (type.contains('battery')) return LucideIcons.zap;
    if (type.contains('ac') || type.contains('electrical')) {
      return LucideIcons.thermometer;
    }
    return LucideIcons.settings;
  }
}
