/// Active Job Panel
///
/// Bottom panel showing current active service request details during navigation.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/service_request.dart';
import '../../domain/models/mechanic_status.dart';

class ActiveJobPanel extends StatelessWidget {
  final ServiceRequest request;
  final MechanicStatus status;
  final String etaText;
  final String distanceText;
  final VoidCallback? onViewDetails;
  final VoidCallback? onCall;
  final VoidCallback? onNavigate;
  final VoidCallback? onArrive;
  final VoidCallback? onComplete;

  const ActiveJobPanel({
    super.key,
    required this.request,
    required this.status,
    this.etaText = '15 minutes',
    this.distanceText = '0 km',
    this.onViewDetails,
    this.onCall,
    this.onNavigate,
    this.onArrive,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Status indicator
          _buildStatusIndicator(),
          const SizedBox(height: 16),

          // Navigation info (if en route)
          if (status == MechanicStatus.enRoute) ...[
            _buildNavigationInfo(),
            const SizedBox(height: 16),
          ],

          // Customer card
          _buildCustomerCard(),
          const SizedBox(height: 16),

          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final isEnRoute = status == MechanicStatus.enRoute;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnRoute
              ? [AppTheme.infoColor, AppTheme.infoTx]
              : [AppTheme.warningColor, AppTheme.orange700],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEnRoute ? Icons.navigation : Icons.build,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isEnRoute ? 'Navigating to Customer' : 'Working on Service',
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppTheme.fontSize14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.infoColor.withValues(alpha: 0.1),
            AppTheme.infoTx.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              icon: Icons.access_time,
              label: 'ETA',
              value: etaText,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.infoColor.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.route,
              label: 'Distance',
              value: distanceText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.infoColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.fontSize18,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSize12,
            color: AppTheme.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard() {
    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.grey200),
        ),
        child: Row(
          children: [
            // Customer avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.warningColor.withValues(alpha: 0.1),
              child: Text(
                request.customerName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: AppTheme.fontSize18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warningColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Customer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.customerName,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getServiceIcon(request.serviceType),
                        size: 14,
                        color: AppTheme.grey600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          request.serviceType,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize13,
                            color: AppTheme.grey600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // View details arrow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.warningColor,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (status == MechanicStatus.working) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle),
              SizedBox(width: 8),
              Text(
                'Complete Service',
                style: TextStyle(
                  fontSize: AppTheme.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // En route buttons
    return Row(
      children: [
        // Call button
        Expanded(
          child: OutlinedButton(
            onPressed: onCall,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.successColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: AppTheme.successColor),
                SizedBox(width: 6),
                Text(
                  'Call',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Arrive button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onArrive,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.infoColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 6),
                Text(
                  'I\'ve Arrived',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getServiceIcon(String serviceType) {
    final type = serviceType.toLowerCase();
    if (type.contains('tire')) return Icons.tire_repair;
    if (type.contains('brake')) return Icons.warning;
    if (type.contains('engine')) return Icons.car_repair;
    if (type.contains('battery')) return Icons.battery_charging_full;
    return Icons.build;
  }
}
