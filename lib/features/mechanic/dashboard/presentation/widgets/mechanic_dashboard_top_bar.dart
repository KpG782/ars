/// Mechanic Dashboard Top Bar
///
/// Top navigation bar with status indicator and menu.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/mechanic_status.dart';

class MechanicDashboardTopBar extends StatelessWidget {
  final MechanicStatus status;
  final bool isOnline;
  final String mechanicName;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const MechanicDashboardTopBar({
    super.key,
    required this.status,
    required this.isOnline,
    this.mechanicName = 'Mechanic',
    this.onMenuTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu button
          GestureDetector(
            onTap: onMenuTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.menu,
                color: AppTheme.onSurfaceColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Status badge and name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $mechanicName',
                  style: AppTheme.figtreeBold.copyWith(
                    fontSize: AppTheme.fontSize16,
                    color: AppTheme.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusBadge(),
              ],
            ),
          ),

          // Notification button
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Icon(
                    LucideIcons.bell,
                    color: AppTheme.onSurfaceColor,
                    size: 22,
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: AppTheme.fontSize12,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case MechanicStatus.offline:
        return AppTheme.grey;
      case MechanicStatus.available:
        return AppTheme.successColor;
      case MechanicStatus.enRoute:
        return AppTheme.infoColor;
      case MechanicStatus.working:
        return AppTheme.warningColor;
      case MechanicStatus.completed:
        return AppTheme.trustColor;
    }
  }

  String _getStatusText() {
    switch (status) {
      case MechanicStatus.offline:
        return 'Offline';
      case MechanicStatus.available:
        return 'Available';
      case MechanicStatus.enRoute:
        return 'En Route';
      case MechanicStatus.working:
        return 'Working';
      case MechanicStatus.completed:
        return 'Completed';
    }
  }
}
