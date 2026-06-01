import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'sub_service_dialogs.dart';

class ServiceSelectionDialog extends StatelessWidget {
  final Function(String) onServiceSelected;
  final Function(String) onSubServiceSelected;
  final String? selectedService;
  final ScrollController scrollController;

  const ServiceSelectionDialog({
    super.key,
    required this.onServiceSelected,
    required this.onSubServiceSelected,
    this.selectedService,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: _ServiceSelectionContent(
        onServiceSelected: (service) {
          onServiceSelected(service);
          Navigator.pop(context);
          _showSubServiceDialog(context, service);
        },
        selectedService: selectedService,
        scrollController: scrollController,
      ),
    );
  }

  void _showSubServiceDialog(BuildContext context, String service) {
    Widget dialog;
    switch (service) {
      case 'Tire Problem':
        dialog = TireProblemOptionsDialog(
          onSubServiceSelected: onSubServiceSelected,
        );
        break;
      case 'Brake Problem':
        dialog = BrakeProblemOptionsDialog(
          onSubServiceSelected: onSubServiceSelected,
        );
        break;
      case 'Engine Problems':
        dialog = EngineProblemOptionsDialog(
          onSubServiceSelected: onSubServiceSelected,
        );
        break;
      case 'Other Car Problems':
        dialog = OtherProblemOptionsDialog(
          onSubServiceSelected: onSubServiceSelected,
        );
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => dialog,
    );
  }
}

class _ServiceSelectionContent extends StatefulWidget {
  final Function(String) onServiceSelected;
  final String? selectedService;
  final ScrollController scrollController;

  const _ServiceSelectionContent({
    required this.onServiceSelected,
    this.selectedService,
    required this.scrollController,
  });

  @override
  State<_ServiceSelectionContent> createState() =>
      _ServiceSelectionContentState();
}

class _ServiceSelectionContentState extends State<_ServiceSelectionContent>
    with SingleTickerProviderStateMixin {
  String? _currentSelection;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedService;
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

  static const List<Map<String, dynamic>> _services = [
    {
      'title': 'Tire Problem',
      'subtitle': 'Flat, busted, or damaged tires? We\'ve got you covered.',
      'icon': Icons.car_repair,
      'color': AppTheme.red300,
    },
    {
      'title': 'Brake Problem',
      'subtitle':
          'Squeaky or unresponsive brakes? Stay safe with expert fixes.',
      'icon': Icons.car_crash,
      'color': AppTheme.warningColor,
    },
    {
      'title': 'Engine Problems',
      'subtitle': 'Engine not running smoothly? Let us diagnose and repair it.',
      'icon': Icons.build_circle,
      'color': AppTheme.infoColor,
    },
    {
      'title': 'Other Car Problems',
      'subtitle': 'For any other car troubles, we\'re here to help!',
      'icon': Icons.settings_suggest,
      'color': AppTheme.successColor,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
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

            // Header with close button
            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 16.0, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi! What service do you need?",
                          style: TextStyle(
                            fontSize: AppTheme.fontSize22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Select a service type to continue",
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
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Services list
            Flexible(
              child: ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(24.0),
                children: _services.asMap().entries.map((entry) {
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
                    child: _buildServiceOption(
                      title: service['title']! as String,
                      subtitle: service['subtitle']! as String,
                      icon: service['icon']! as IconData,
                      color: service['color']! as Color,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Continue button
            Container(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentSelection != null
                        ? AppTheme.primaryColor
                        : AppTheme.grey300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _currentSelection != null ? 4 : 0,
                  ),
                  onPressed: _currentSelection != null
                      ? () {
                          widget.onServiceSelected(_currentSelection!);
                        }
                      : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize18,
                          fontWeight: FontWeight.bold,
                          color: _currentSelection != null
                              ? Colors.white
                              : AppTheme.grey600,
                        ),
                      ),
                      if (_currentSelection != null) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final bool isSelected = _currentSelection == title;
    return GestureDetector(
      onTap: () => setState(() => _currentSelection = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.successBg : AppTheme.grey50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
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
                color: isSelected ? color.withValues(alpha: 0.2) : Colors.white,
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
                      color: isSelected
                          ? AppTheme.onSurfaceColor
                          : AppTheme.subtitleColor,
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
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.grey400,
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
