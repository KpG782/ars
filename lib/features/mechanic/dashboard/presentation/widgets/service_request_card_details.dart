import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/service_request.dart';

class ServiceRequestCardDetails extends StatelessWidget {
  final ServiceRequest request;

  const ServiceRequestCardDetails({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: AppTheme.fontSize13_5,
            color: AppTheme.subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppTheme.subtitleColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${request.location.latitude.toStringAsFixed(4)}, ${request.location.longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize12,
                  color: AppTheme.subtitleColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
