/// Sub-Service Selection Panel
///
/// Shows sub-service options based on the selected main service type.
library;

import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class SubServiceSelectionPanel extends StatefulWidget {
  final String selectedService;
  final Function(String) onSubServiceSelected;
  final VoidCallback onBack;

  const SubServiceSelectionPanel({
    super.key,
    required this.selectedService,
    required this.onSubServiceSelected,
    required this.onBack,
  });

  @override
  State<SubServiceSelectionPanel> createState() =>
      _SubServiceSelectionPanelState();
}

class _SubServiceSelectionPanelState extends State<SubServiceSelectionPanel>
    with SingleTickerProviderStateMixin {
  String? _selectedOption;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  Map<String, dynamic> _getServiceData() {
    switch (widget.selectedService) {
      case 'Tire Problem':
        return {
          'title': 'Tire Problem',
          'subtitle': 'What specific tire issue are you experiencing?',
          'icon': Icons.car_repair,
          'iconColor': AppTheme.red300,
          'options': const [
            {'name': 'Flat Tire', 'icon': Icons.report_problem},
            {'name': 'Tire Replacement', 'icon': Icons.autorenew},
            {'name': 'Tire Repair', 'icon': Icons.build},
            {'name': 'Tire Installation', 'icon': Icons.add_circle_outline},
          ],
        };
      case 'Brake Problem':
        return {
          'title': 'Brake Problem',
          'subtitle': 'Which brake service do you need?',
          'icon': Icons.car_crash,
          'iconColor': AppTheme.warningColor,
          'options': const [
            {'name': 'Brake Pad Replacement', 'icon': Icons.repeat},
            {'name': 'Brake Fluid Check', 'icon': Icons.water_drop},
            {'name': 'Brake Repair', 'icon': Icons.build_circle},
            {'name': 'Brake System Diagnosis', 'icon': Icons.search},
          ],
        };
      case 'Engine Problems':
        return {
          'title': 'Engine Problems',
          'subtitle': 'What engine service do you require?',
          'icon': Icons.build_circle,
          'iconColor': AppTheme.infoColor,
          'options': const [
            {'name': 'Engine Diagnosis', 'icon': Icons.query_stats},
            {'name': 'Oil Change', 'icon': Icons.oil_barrel},
            {'name': 'Engine Repair', 'icon': Icons.construction},
            {'name': 'Engine Tune-up', 'icon': Icons.tune},
          ],
        };
      case 'Other Car Problems':
        return {
          'title': 'Other Car Problems',
          'subtitle': 'Select the service you need',
          'icon': Icons.settings_suggest,
          'iconColor': AppTheme.successColor,
          'options': const [
            {'name': 'Battery Issue', 'icon': Icons.battery_alert},
            {'name': 'AC Problem', 'icon': Icons.ac_unit},
            {'name': 'Electrical Issue', 'icon': Icons.electrical_services},
            {'name': 'General Inspection', 'icon': Icons.fact_check},
          ],
        };
      default:
        return {
          'title': 'Select Service',
          'subtitle': 'Choose a sub-service',
          'icon': Icons.build,
          'iconColor': AppTheme.grey,
          'options': const [],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceData = _getServiceData();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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

              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24.0, 20.0, 16.0, 0),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (serviceData['iconColor'] as Color).withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        serviceData['icon'] as IconData,
                        color: serviceData['iconColor'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceData['title'] as String,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            serviceData['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize13,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.grey),
                      onPressed: widget.onBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Options list
              Flexible(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                  children:
                      (serviceData['options'] as List<Map<String, dynamic>>)
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 300 + (index * 80),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 15 * (1 - value)),
                                  child: Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildOptionTile(
                                option['name']! as String,
                                option['icon']! as IconData,
                                serviceData['iconColor'] as Color,
                              ),
                            );
                          })
                          .toList(),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption != null
                          ? AppTheme.primaryColor
                          : AppTheme.grey300,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _selectedOption != null ? 4 : 0,
                    ),
                    onPressed: _selectedOption != null
                        ? () => widget.onSubServiceSelected(_selectedOption!)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Service',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                            color: _selectedOption != null
                                ? Colors.white
                                : AppTheme.grey600,
                          ),
                        ),
                        if (_selectedOption != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check_circle, size: 18),
                        ],
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

  Widget _buildOptionTile(String option, IconData icon, Color iconColor) {
    final bool isSelected = _selectedOption == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.successBg : AppTheme.grey50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Service icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? iconColor.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? iconColor : AppTheme.grey300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? iconColor : AppTheme.grey600,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Option name
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.onSurfaceColor
                      : AppTheme.subtitleColor,
                ),
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.grey400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
