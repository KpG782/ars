/// Nearby Requests Panel
///
/// Bottom panel showing list of nearby service requests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/service_semantics.dart';
import '../../domain/models/service_request.dart';

class NearbyRequestsPanel extends StatelessWidget {
  final List<ServiceRequest> requests;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Function(ServiceRequest)? onRequestTap;

  const NearbyRequestsPanel({
    super.key,
    required this.requests,
    this.isLoading = false,
    this.onRefresh,
    this.onRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 14, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Nearby Requests',
                          style: AppTheme.figtreeExtraBold.copyWith(
                            fontSize: AppTheme.fontSize18,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${requests.length}',
                            style: AppTheme.figtreeSemiBold.copyWith(
                              fontSize: AppTheme.fontSize13,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onRefresh,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Icon(
                          LucideIcons.refresh_cw,
                          color: isLoading
                              ? AppTheme.subtitleColor
                              : AppTheme.primaryColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Requests list
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      )
                    : requests.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          return _buildRequestCard(requests[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.map_pin_off,
            size: 56,
            color: AppTheme.borderColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No nearby requests',
            style: AppTheme.figtreeSemiBold.copyWith(
              fontSize: AppTheme.fontSize16,
              color: AppTheme.subtitleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'New requests will appear here',
            style: AppTheme.figtreeRegular.copyWith(
              fontSize: AppTheme.fontSize13,
              color: AppTheme.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ServiceRequest request) {
    final semantic = ServiceSemanticTheme.resolve(
      request.serviceType,
      isEmergency: request.isEmergency,
    );
    final Color accentColor = semantic.accentColor;
    final Color bgColor = semantic.backgroundColor;

    return GestureDetector(
      onTap: () => onRequestTap?.call(request),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1,
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
            // Accent strip
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service type row
                  Row(
                    children: [
                      Icon(semantic.icon, size: 16, color: accentColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          request.serviceType,
                          style: AppTheme.figtreeSemiBold.copyWith(
                            fontSize: AppTheme.fontSize15,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                      ),
                      if (request.isEmergency)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.emergencyColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'URGENT',
                            style: AppTheme.figtreeSemiBold.copyWith(
                              color: Colors.white,
                              fontSize: AppTheme.fontSize10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.customerName,
                    style: AppTheme.figtreeRegular.copyWith(
                      fontSize: AppTheme.fontSize13,
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.figtreeRegular.copyWith(
                      fontSize: AppTheme.fontSize12,
                      color: AppTheme.subtitleColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.clock,
                            size: 13,
                            color: AppTheme.subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(request.requestTime),
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize12,
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₱${request.estimatedPrice.toStringAsFixed(0)}',
                        style: AppTheme.figtreeExtraBold.copyWith(
                          fontSize: AppTheme.fontSize16,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${diff.inHours}h ago';
    }
  }
}
