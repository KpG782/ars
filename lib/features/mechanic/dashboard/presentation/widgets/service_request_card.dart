import 'package:flutter/material.dart';

import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/theme/service_semantics.dart';
import '../../domain/models/service_request.dart';
import 'service_request_card_actions.dart';
import 'service_request_card_details.dart';
import 'service_request_card_header.dart';
import 'service_request_status_badge.dart';

class ServiceRequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onAccept;
  final VoidCallback? onReject;

  const ServiceRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = ServiceSemanticTheme.resolve(
      request.serviceType,
      isEmergency: request.isEmergency,
    );
    final Color accentColor = semantic.accentColor;
    final Color bgColor = semantic.backgroundColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: request.isEmergency
              ? AppTheme.emergencyColor.withValues(alpha: 0.4)
              : accentColor.withValues(alpha: 0.3),
          width: request.isEmergency ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent strip
          Container(
            width: 4,
            constraints: const BoxConstraints(minHeight: 70),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServiceRequestStatusBadge(request: request),
                const SizedBox(height: 10),
                ServiceRequestCardHeader(request: request),
                const SizedBox(height: 8),
                ServiceRequestCardDetails(request: request),
                const SizedBox(height: 12),
                ServiceRequestCardActions(
                  request: request,
                  onAccept: onAccept,
                  onReject: onReject,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
