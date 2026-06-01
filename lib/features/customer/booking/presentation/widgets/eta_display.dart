import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/utils/app_logger.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../../../../core/services/osrm_service.dart';

/// Widget that displays real-time ETA and distance between two locations
///
/// Automatically refreshes every 30 seconds to keep ETA updated
/// Shows accuracy indicator when using fallback calculation
class ETADisplay extends StatefulWidget {
  final LatLng mechanicLocation;
  final LatLng customerLocation;
  final String? mechanicName;

  const ETADisplay({
    super.key,
    required this.mechanicLocation,
    required this.customerLocation,
    this.mechanicName,
  });

  @override
  State<ETADisplay> createState() => _ETADisplayState();
}

class _ETADisplayState extends State<ETADisplay> {
  ETAResult? _eta;
  bool _loading = true;
  Timer? _timer;
  final _osrm = OSRMService();

  @override
  void initState() {
    super.initState();
    _updateETA();
    // Refresh every 30 seconds for real-time updates
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateETA());
  }

  Future<void> _updateETA() async {
    try {
      final result = await _osrm.calculateETA(
        origin: widget.mechanicLocation,
        destination: widget.customerLocation,
      );

      if (mounted) {
        setState(() {
          _eta = result;
          _loading = false;
        });
      }
    } catch (e) {
      appLogger.w('ETA error: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Calculating route...',
                style: TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_eta == null) {
      return Card(
        color: AppTheme.red50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppTheme.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Unable to calculate ETA',
                  style: TextStyle(color: AppTheme.red),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and mechanic name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mechanicName ?? 'Mechanic',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'is arriving in',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize12,
                          color: AppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_eta!.isAccurate)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.orange100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 12,
                          color: AppTheme.orange900,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Estimate',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.orange900,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Large ETA display
            Center(
              child: Column(
                children: [
                  Text(
                    _eta!.durationText,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _eta!.distanceText,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize18,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.grey700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: AppTheme.borderColor,
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
              ),
            ),

            const SizedBox(height: 12),

            // Footer info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.update, size: 14, color: AppTheme.grey600),
                    SizedBox(width: 4),
                    Text(
                      'Auto-refresh',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize11,
                        color: AppTheme.grey600,
                      ),
                    ),
                  ],
                ),
                if (_eta!.isAccurate)
                  const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppTheme.green600,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Accurate route',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize11,
                          color: AppTheme.green600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact ETA display for list items or smaller spaces
class CompactETADisplay extends StatelessWidget {
  final LatLng mechanicLocation;
  final LatLng customerLocation;

  const CompactETADisplay({
    super.key,
    required this.mechanicLocation,
    required this.customerLocation,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ETAResult>(
      future: OSRMService().calculateETA(
        origin: mechanicLocation,
        destination: customerLocation,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 6),
              Text('...', style: TextStyle(fontSize: AppTheme.fontSize12)),
            ],
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: AppTheme.red),
              SizedBox(width: 4),
              Text(
                'N/A',
                style: TextStyle(
                  fontSize: AppTheme.fontSize12,
                  color: AppTheme.red,
                ),
              ),
            ],
          );
        }

        final eta = snapshot.data!;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                eta.durationText,
                style: const TextStyle(
                  fontSize: AppTheme.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              if (!eta.isAccurate) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.info_outline,
                  size: 10,
                  color: AppTheme.orange700,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
