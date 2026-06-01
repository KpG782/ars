/// Emergency Panel
///
/// Shows emergency service options for urgent roadside assistance.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class EmergencyPanel extends StatefulWidget {
  final Function(String) onEmergencyServiceSelected;
  final VoidCallback onCancel;

  const EmergencyPanel({
    super.key,
    required this.onEmergencyServiceSelected,
    required this.onCancel,
  });

  @override
  State<EmergencyPanel> createState() => _EmergencyPanelState();
}

class _EmergencyPanelState extends State<EmergencyPanel>
    with SingleTickerProviderStateMixin {
  String? _selectedEmergency;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const List<Map<String, dynamic>> _emergencyServices = [
    {
      'title': 'Flat Tire',
      'subtitle': 'Tire puncture or blowout',
      'icon': Icons.car_repair,
      'color': AppTheme.red300,
    },
    {
      'title': 'Out of Fuel',
      'subtitle': 'Vehicle ran out of gas',
      'icon': Icons.local_gas_station,
      'color': AppTheme.warningColor,
    },
    {
      'title': 'Engine Problem',
      'subtitle': 'Engine overheating or failure',
      'icon': Icons.build_circle,
      'color': AppTheme.emergencyColor,
    },
    {
      'title': 'Battery Dead',
      'subtitle': 'Car won\'t start',
      'icon': Icons.battery_alert,
      'color': AppTheme.primaryColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      snap: true,
      builder: (context, scrollController) => FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with back button
              Container(
                padding: const EdgeInsets.fromLTRB(24.0, 12.0, 16.0, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Emergency Service",
                            style: TextStyle(
                              fontSize: AppTheme.fontSize22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.red,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Select your emergency type",
                            style: TextStyle(
                              fontSize: AppTheme.fontSize14,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.grey),
                      onPressed: widget.onCancel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Emergency services list
              Flexible(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  children: _emergencyServices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final service = entry.value;
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: _buildEmergencyOption(
                        title: service['title']! as String,
                        subtitle: service['subtitle']! as String,
                        icon: service['icon']! as IconData,
                        color: service['color']! as Color,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Confirm button
              Container(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedEmergency != null
                          ? AppTheme.red
                          : AppTheme.grey300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _selectedEmergency != null ? 4 : 0,
                    ),
                    onPressed: _selectedEmergency != null
                        ? () => widget.onEmergencyServiceSelected(
                            _selectedEmergency!,
                          )
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Request Emergency Service',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize18,
                            fontWeight: FontWeight.bold,
                            color: _selectedEmergency != null
                                ? Colors.white
                                : AppTheme.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final bool isSelected = _selectedEmergency == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedEmergency = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.red.withValues(alpha: 0.05)
              : AppTheme.grey50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.red : AppTheme.grey300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.red.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon with background
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppTheme.grey300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : AppTheme.grey600,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTheme.fontSize16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.red : AppTheme.subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize13,
                      color: AppTheme.grey600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.red : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.red : AppTheme.grey400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
