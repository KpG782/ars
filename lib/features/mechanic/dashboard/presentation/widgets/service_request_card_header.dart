import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/service_request.dart';

class ServiceRequestCardHeader extends StatelessWidget {
  final ServiceRequest request;

  const ServiceRequestCardHeader({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: const Icon(LucideIcons.user, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.customerName,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                request.serviceType,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize13,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          'PHP ${request.estimatedPrice.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}
