import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/service_request.dart';

class ServiceRequestCardActions extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onAccept;
  final VoidCallback? onReject;

  const ServiceRequestCardActions({
    super.key,
    required this.request,
    required this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReject,
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: request.isEmergency
                  ? AppTheme.red
                  : AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(request.isEmergency ? 'Accept Urgent' : 'Accept'),
          ),
        ),
      ],
    );
  }
}
