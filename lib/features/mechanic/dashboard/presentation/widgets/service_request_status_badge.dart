import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/service_request.dart';

class ServiceRequestStatusBadge extends StatelessWidget {
  final ServiceRequest request;

  const ServiceRequestStatusBadge({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    if (request.isEmergency) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'EMERGENCY REQUEST',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.grey200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Pending',
          style: TextStyle(
            fontSize: AppTheme.fontSize11_5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
