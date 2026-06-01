/// Service Request Details Sheet
///
/// Bottom sheet for displaying service request details and actions.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/service_request.dart';

class ServiceRequestDetailsSheet extends StatelessWidget {
  final ServiceRequest request;
  final String etaText;
  final String distanceText;
  final bool isEnRoute;
  final bool isWorking;
  final VoidCallback? onAccept;
  final VoidCallback? onArrive;
  final VoidCallback? onComplete;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const ServiceRequestDetailsSheet({
    super.key,
    required this.request,
    this.etaText = '15 minutes',
    this.distanceText = '0 km',
    this.isEnRoute = false,
    this.isWorking = false,
    this.onAccept,
    this.onArrive,
    this.onComplete,
    this.onCall,
    this.onMessage,
  });

  /// Show as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required ServiceRequest request,
    String etaText = '15 minutes',
    String distanceText = '0 km',
    bool isEnRoute = false,
    bool isWorking = false,
    VoidCallback? onAccept,
    VoidCallback? onArrive,
    VoidCallback? onComplete,
    VoidCallback? onCall,
    VoidCallback? onMessage,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceRequestDetailsSheet(
        request: request,
        etaText: etaText,
        distanceText: distanceText,
        isEnRoute: isEnRoute,
        isWorking: isWorking,
        onAccept: onAccept,
        onArrive: onArrive,
        onComplete: onComplete,
        onCall: onCall,
        onMessage: onMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header with emergency badge
                _buildHeader(),
                const SizedBox(height: 16),

                // Customer info
                _buildCustomerInfo(),
                const SizedBox(height: 16),

                // Service details
                _buildServiceDetails(),
                const SizedBox(height: 16),

                // ETA and Distance (if en route)
                if (isEnRoute || isWorking) ...[
                  _buildNavigationInfo(),
                  const SizedBox(height: 16),
                ],

                // Price breakdown
                _buildPriceBreakdown(),
                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            request.serviceType,
            style: const TextStyle(
              fontSize: AppTheme.fontSize22,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceColor,
            ),
          ),
        ),
        if (request.isEmergency)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'EMERGENCY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTheme.fontSize12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.warningColor.withValues(alpha: 0.1),
                child: Text(
                  request.customerName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningColor,
                  ),
                ),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatRequestTime(request.requestTime),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              // Contact buttons
              Row(
                children: [
                  _buildContactButton(
                    icon: Icons.phone,
                    color: AppTheme.successColor,
                    onTap: onCall,
                  ),
                  const SizedBox(width: 8),
                  _buildContactButton(
                    icon: Icons.message,
                    color: AppTheme.infoColor,
                    onTap: onMessage,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Details',
          style: TextStyle(
            fontSize: AppTheme.fontSize16,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          request.description,
          style: const TextStyle(
            fontSize: AppTheme.fontSize14,
            color: AppTheme.grey700,
            height: 1.4,
          ),
        ),
        if (request.customerNotes != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note, size: 18, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.customerNotes!,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize13,
                      color: AppTheme.warningTx,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.infoColor, AppTheme.infoTx],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildNavInfoItem(
              icon: Icons.access_time,
              label: 'ETA',
              value: etaText,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(
            child: _buildNavInfoItem(
              icon: Icons.route,
              label: 'Distance',
              value: distanceText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: AppTheme.fontSize18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: AppTheme.fontSize12,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final hasDiscount = request.discountApplied > 0;
    final hasTip = request.tipAmount > 0;
    final finalPrice =
        request.estimatedPrice - request.discountApplied + request.tipAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Service Fee',
            '₱${request.estimatedPrice.toStringAsFixed(2)}',
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Discount (${request.appliedPromoCode})',
              '-₱${request.discountApplied.toStringAsFixed(2)}',
              valueColor: AppTheme.successColor,
            ),
          ],
          if (hasTip) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Tip',
              '+₱${request.tipAmount.toStringAsFixed(2)}',
              valueColor: AppTheme.warningColor,
            ),
          ],
          const Divider(height: 24),
          _buildPriceRow(
            'Total',
            '₱${finalPrice.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: AppTheme.grey700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppTheme.grey800,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isWorking) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onComplete?.call();
          },
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
                'Mark Service Complete',
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

    if (isEnRoute) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onArrive?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.infoColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on),
              SizedBox(width: 8),
              Text(
                'I\'ve Arrived',
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

    // Available - show accept button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          onAccept?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.warningColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check),
            SizedBox(width: 8),
            Text(
              'Accept Request',
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

  String _formatRequestTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    }
  }
}
