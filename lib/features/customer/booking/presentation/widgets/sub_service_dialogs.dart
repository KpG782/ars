import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class TireProblemOptionsDialog extends StatelessWidget {
  final Function(String) onSubServiceSelected;

  const TireProblemOptionsDialog({
    super.key,
    required this.onSubServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SubServiceDialog(
      title: 'Tire Problem',
      subtitle: 'What specific tire issue are you experiencing?',
      icon: Icons.car_repair,
      iconColor: AppTheme.red300,
      options: const [
        {'name': 'Flat Tire', 'icon': Icons.report_problem},
        {'name': 'Tire Replacement', 'icon': Icons.autorenew},
        {'name': 'Tire Repair', 'icon': Icons.build},
        {'name': 'Tire Installation', 'icon': Icons.add_circle_outline},
      ],
      onSubServiceSelected: onSubServiceSelected,
    );
  }
}

class BrakeProblemOptionsDialog extends StatelessWidget {
  final Function(String) onSubServiceSelected;

  const BrakeProblemOptionsDialog({
    super.key,
    required this.onSubServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SubServiceDialog(
      title: 'Brake Problem',
      subtitle: 'Which brake service do you need?',
      icon: Icons.car_crash,
      iconColor: AppTheme.warningColor,
      options: const [
        {'name': 'Brake Pad Replacement', 'icon': Icons.repeat},
        {'name': 'Brake Fluid Check', 'icon': Icons.water_drop},
        {'name': 'Brake Repair', 'icon': Icons.build_circle},
        {'name': 'Brake System Diagnosis', 'icon': Icons.search},
      ],
      onSubServiceSelected: onSubServiceSelected,
    );
  }
}

class EngineProblemOptionsDialog extends StatelessWidget {
  final Function(String) onSubServiceSelected;

  const EngineProblemOptionsDialog({
    super.key,
    required this.onSubServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SubServiceDialog(
      title: 'Engine Problems',
      subtitle: 'What engine service do you require?',
      icon: Icons.build_circle,
      iconColor: AppTheme.infoColor,
      options: const [
        {'name': 'Engine Diagnosis', 'icon': Icons.query_stats},
        {'name': 'Oil Change', 'icon': Icons.oil_barrel},
        {'name': 'Engine Repair', 'icon': Icons.construction},
        {'name': 'Engine Tune-up', 'icon': Icons.tune},
      ],
      onSubServiceSelected: onSubServiceSelected,
    );
  }
}

class OtherProblemOptionsDialog extends StatelessWidget {
  final Function(String) onSubServiceSelected;

  const OtherProblemOptionsDialog({
    super.key,
    required this.onSubServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _SubServiceDialog(
      title: 'Other Car Problems',
      subtitle: 'Select the service you need',
      icon: Icons.settings_suggest,
      iconColor: AppTheme.successColor,
      options: const [
        {'name': 'Battery Issue', 'icon': Icons.battery_alert},
        {'name': 'AC Problem', 'icon': Icons.ac_unit},
        {'name': 'Electrical Issue', 'icon': Icons.electrical_services},
        {'name': 'General Inspection', 'icon': Icons.fact_check},
      ],
      onSubServiceSelected: onSubServiceSelected,
    );
  }
}

class _SubServiceDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Map<String, dynamic>> options;
  final Function(String) onSubServiceSelected;

  const _SubServiceDialog({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.options,
    required this.onSubServiceSelected,
  });

  @override
  State<_SubServiceDialog> createState() => _SubServiceDialogState();
}

class _SubServiceDialogState extends State<_SubServiceDialog>
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxDialogHeight = screenHeight * 0.85; // 85% of screen height

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 450,
            maxHeight: maxDialogHeight,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                        color: widget.iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
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
                            widget.title,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurfaceColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize13,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.grey),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Options list
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 80)),
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
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppTheme.grey300),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.subtitleColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
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
                              ? () {
                                  widget.onSubServiceSelected(_selectedOption!);
                                  Navigator.pop(context);
                                }
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(String option, IconData icon) {
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
                    ? widget.iconColor.withValues(alpha: 0.15)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? widget.iconColor : AppTheme.grey300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? widget.iconColor : AppTheme.grey600,
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
