import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/services/location_sharing_service.dart';

class ShareLocationSheet extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String customerName;
  final String mechanicName;
  final String eta;

  const ShareLocationSheet({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.customerName,
    required this.mechanicName,
    required this.eta,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final message = LocationSharingService.buildMessage(
      latitude: latitude,
      longitude: longitude,
      customerName: customerName,
      mechanicName: mechanicName,
      eta: eta,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.6, // Max 60% of screen height
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Compact Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.share_location,
                          color: AppTheme.primaryDark,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Share Live Location',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Google Maps Location Preview
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.green50, AppTheme.surfaceColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.successColor),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.map, color: AppTheme.green700, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Google Maps Location',
                              style: TextStyle(
                                fontSize: AppTheme.fontSize14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.green700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lat: ${latitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize12,
                            color: AppTheme.green700,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'Lng: ${longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize12,
                            color: AppTheme.green700,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Share Options - Compact Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    children: [
                      _ShareOptionCard(
                        icon: Icons.sms,
                        label: 'SMS',
                        color: AppTheme.green,
                        onTap: () async {
                          Navigator.pop(context);
                          await Share.share(
                            message,
                            subject: '🚨 Emergency Location Alert',
                          );
                        },
                      ),
                      _ShareOptionCard(
                        icon: Icons.facebook,
                        label: 'Messenger',
                        color: AppTheme.infoColor,
                        onTap: () async {
                          Navigator.pop(context);
                          await Share.share(
                            message,
                            subject: '🚨 Emergency Location Alert',
                          );
                        },
                      ),
                      _ShareOptionCard(
                        icon: Icons.phone_android,
                        label: 'WhatsApp',
                        color: AppTheme.successColor,
                        onTap: () async {
                          Navigator.pop(context);
                          await Share.share(
                            message,
                            subject: '🚨 Emergency Location Alert',
                          );
                        },
                      ),
                      _ShareOptionCard(
                        icon: Icons.copy,
                        label: 'Copy Link',
                        color: Colors.purple,
                        onTap: () async {
                          await LocationSharingService.copyToClipboard(
                            message: message,
                            context: context,
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Compact Info box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.blue50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.blue200),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.blue700,
                          size: 16,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Link opens in Google Maps. Works on any phone.',
                            style: TextStyle(
                              fontSize: AppTheme.fontSize12,
                              color: AppTheme.blue700,
                            ),
                          ),
                        ),
                      ],
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
}

class _ShareOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOptionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTheme.fontSize12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
