import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'booking_enums.dart';

class BookingDetailsPanel extends StatelessWidget {
  final String? selectedSubService;
  final Function(BookingStatus) onBookingStatusChanged;

  const BookingDetailsPanel({
    super.key,
    required this.selectedSubService,
    required this.onBookingStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: AppTheme.fontSize22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Service Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Service:',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize14,
                        color: AppTheme.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedSubService ?? 'Selected Service',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Location Info
              const Row(
                children: [
                  Icon(Icons.location_on, color: AppTheme.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your Current Location',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(onPressed: null, child: Text('Change')),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          onBookingStatusChanged(BookingStatus.initial),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () =>
                          onBookingStatusChanged(BookingStatus.searching),
                      child: const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchingPanel extends StatefulWidget {
  final String? selectedSubService;

  const SearchingPanel({super.key, required this.selectedSubService});

  @override
  State<SearchingPanel> createState() => _SearchingPanelState();
}

class _SearchingPanelState extends State<SearchingPanel>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Search Icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Searching for nearby mechanics...',
                style: TextStyle(
                  fontSize: AppTheme.fontSize20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Service: ${widget.selectedSubService ?? 'Selected Service'}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Progress Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              const Text(
                'This may take a few moments...',
                style: TextStyle(
                  fontSize: AppTheme.fontSize12,
                  color: AppTheme.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MechanicConfirmedPanel extends StatelessWidget {
  final String? selectedSubService;
  final VoidCallback onResetBooking;

  const MechanicConfirmedPanel({
    super.key,
    required this.selectedSubService,
    required this.onResetBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 50,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Mechanic Confirmed!',
                style: TextStyle(
                  fontSize: AppTheme.fontSize22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Service: ${selectedSubService ?? 'Selected Service'}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Mechanic Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(Icons.person, color: Colors.white, size: 25),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'John Mechanic',
                            style: TextStyle(
                              fontSize: AppTheme.fontSize16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Arriving in 15 minutes',
                            style: TextStyle(
                              fontSize: AppTheme.fontSize12,
                              color: AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: null,
                          icon: Icon(Icons.phone, color: AppTheme.primaryColor),
                        ),
                        IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.message,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Track Mechanic',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: onResetBooking,
                      child: const Text(
                        'New Booking',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
