import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class ServiceInfoBanner extends StatelessWidget {
  final String serviceType;
  final String status;

  const ServiceInfoBanner({
    super.key,
    required this.serviceType,
    this.status = 'Active',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppTheme.trustBg,
      child: Row(
        children: [
          const Icon(LucideIcons.wrench, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Service: $serviceType',
              style: const TextStyle(
                fontSize: AppTheme.fontSize15,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: AppTheme.fontSize13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
