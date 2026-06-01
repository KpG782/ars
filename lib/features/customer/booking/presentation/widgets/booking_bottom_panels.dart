import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'booking_enums.dart';
import 'share_location_sheet.dart';
import '../../domain/models/mechanic.dart';
import '../screens/ai_chat_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/payment/payment_details_screen.dart';
import 'package:latlong2/latlong.dart';
import 'eta_display.dart';

class BookingBottomPanels extends StatelessWidget {
  final BookingStatus bookingStatus;
  final String? selectedService;
  final String? selectedSubService;
  final Function(String) onServiceSelected;
  final Function(String) onSubServiceSelected;
  final Function(BookingStatus) onBookingStatusChanged;
  final VoidCallback onResetBooking;
  final VoidCallback? onEmergencyPressed;
  final Mechanic? mechanic;
  final LatLng customerLocation; // Add customer location

  const BookingBottomPanels({
    super.key,
    required this.bookingStatus,
    required this.selectedService,
    required this.selectedSubService,
    required this.onServiceSelected,
    required this.onSubServiceSelected,
    required this.onBookingStatusChanged,
    required this.onResetBooking,
    this.onEmergencyPressed,
    this.mechanic,
    required this.customerLocation, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    switch (bookingStatus) {
      case BookingStatus.emergency:
        return _EmergencyBottomPanel(
          onEmergencyServiceSelected: (service) {
            onSubServiceSelected(service);
            onBookingStatusChanged(BookingStatus.searching);
          },
          onCancel: onResetBooking,
        );
      case BookingStatus.initial:
        return _InitialBottomPanel(
          selectedService: selectedService,
          selectedSubService: selectedSubService,
          onServiceSelected: (service) {
            onServiceSelected(service);
            // Check if service requires sub-service selection
            final servicesWithSubOptions = [
              'Tire Problem',
              'Brake Problem',
              'Engine Problems',
              'Other Car Problems',
            ];
            if (servicesWithSubOptions.contains(service)) {
              onBookingStatusChanged(BookingStatus.subServiceSelection);
            } else {
              onBookingStatusChanged(BookingStatus.searching);
            }
          },
          onBookingStatusChanged: onBookingStatusChanged,
          onEmergencyPressed: onEmergencyPressed,
        );
      case BookingStatus.serviceSelection:
        return _ServiceSelectionBottomPanel(
          selectedService: selectedService,
          onServiceSelected: (service) {
            onServiceSelected(service);
            // Check if service requires sub-service selection
            final servicesWithSubOptions = [
              'Tire Problem',
              'Brake Problem',
              'Engine Problems',
              'Other Car Problems',
            ];
            if (servicesWithSubOptions.contains(service)) {
              onBookingStatusChanged(BookingStatus.subServiceSelection);
            } else {
              onBookingStatusChanged(BookingStatus.searching);
            }
          },
          onBack: () => onBookingStatusChanged(BookingStatus.initial),
        );
      case BookingStatus.subServiceSelection:
        return _SubServiceSelectionBottomPanel(
          selectedService: selectedService!,
          onSubServiceSelected: (subService) {
            onSubServiceSelected(subService);
            onBookingStatusChanged(BookingStatus.searching);
          },
          onBack: () => onBookingStatusChanged(BookingStatus.serviceSelection),
        );
      case BookingStatus.details:
        return _BookingDetailsPanel(
          selectedSubService: selectedSubService,
          onBookingStatusChanged: onBookingStatusChanged,
        );
      case BookingStatus.searching:
        return _SearchingPanel(
          selectedSubService: selectedSubService,
          onCancel: onResetBooking,
        );
      case BookingStatus.confirmed:
        return _MechanicConfirmedPanel(
          selectedSubService: selectedSubService,
          onResetBooking: onResetBooking,
          mechanic: mechanic,
          customerLocation: customerLocation, // Pass customer location
        );
    }
  }
}

class _InitialBottomPanel extends StatelessWidget {
  final String? selectedService;
  final String? selectedSubService;
  final Function(String) onServiceSelected;
  final Function(BookingStatus) onBookingStatusChanged;
  final VoidCallback? onEmergencyPressed;

  const _InitialBottomPanel({
    required this.selectedService,
    required this.selectedSubService,
    required this.onServiceSelected,
    required this.onBookingStatusChanged,
    this.onEmergencyPressed,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = selectedService ?? 'Choose Service';
    if (selectedSubService != null) {
      displayText = '$selectedService: $selectedSubService';
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.15,
      maxChildSize: 0.3,
      snap: true,
      snapSizes: const [0.15, 0.18],
      builder: (context, scrollController) => Container(
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
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 30.0),
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            InkWell(
              onTap: () =>
                  onBookingStatusChanged(BookingStatus.serviceSelection),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.grey200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.grey400),
                      ),
                      child: Icon(
                        selectedService != null ? Icons.check : Icons.add,
                        color: selectedService != null
                            ? AppTheme.primaryColor
                            : AppTheme.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        displayText,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSize18,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.grey,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (onEmergencyPressed != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onEmergencyPressed,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.red,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Emergency SOS',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingDetailsPanel extends StatelessWidget {
  final String? selectedSubService;
  final Function(BookingStatus) onBookingStatusChanged;

  const _BookingDetailsPanel({
    required this.selectedSubService,
    required this.onBookingStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.18,
      maxChildSize: 0.4,
      snap: true,
      snapSizes: const [0.18, 0.25],
      builder: (context, scrollController) => Container(
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
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 20.0),
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: AppTheme.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Service: ${selectedSubService ?? 'Selected Service'}',
              style: const TextStyle(fontSize: AppTheme.fontSize16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        onBookingStatusChanged(BookingStatus.initial),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    onPressed: () =>
                        onBookingStatusChanged(BookingStatus.searching),
                    child: const Text('Confirm Booking'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchingPanel extends StatelessWidget {
  final String? selectedSubService;
  final VoidCallback onCancel;

  const _SearchingPanel({
    required this.selectedSubService,
    required this.onCancel,
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
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Searching for nearby mechanics...',
                style: TextStyle(
                  fontSize: AppTheme.fontSize18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Service: ${selectedSubService ?? 'Selected Service'}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close, color: AppTheme.red, size: 20),
                  label: const Text(
                    'Cancel Search',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.red,
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
}

class _MechanicConfirmedPanel extends StatelessWidget {
  final String? selectedSubService;
  final VoidCallback onResetBooking;
  final Mechanic? mechanic;
  final LatLng customerLocation;

  const _MechanicConfirmedPanel({
    required this.selectedSubService,
    required this.onResetBooking,
    this.mechanic,
    required this.customerLocation,
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Compact Status Row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mechanic on the way!',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          selectedSubService ?? 'Service',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Compact ETA Display using CompactETADisplay
              if (mechanic != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mechanic!.name,
                              style: const TextStyle(
                                fontSize: AppTheme.fontSize14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            CompactETADisplay(
                              mechanicLocation: mechanic!.location,
                              customerLocation: customerLocation,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                mechanic: mechanic!,
                                serviceType: selectedSubService ?? 'Service',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.message,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // Share Location Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      isDismissible: true,
                      builder: (context) => ShareLocationSheet(
                        latitude: customerLocation.latitude,
                        longitude: customerLocation.longitude,
                        customerName: 'Customer',
                        mechanicName: mechanic?.name ?? 'Mechanic',
                        eta: '5-10 min',
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppTheme.primarySurface,
                  ),
                  icon: const Icon(
                    Icons.share_location,
                    color: AppTheme.primaryDark,
                    size: 18,
                  ),
                  label: const Text(
                    'Share Live Location with Family',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Chat with AI while mechanic is on the way
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AiChatScreen(sessionId: 'booking_$uid'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.smart_toy, size: 20),
                  label: const Text(
                    'Chat with AI while you wait',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Compact Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onResetBooking,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppTheme.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: AppTheme.red,
                        size: 18,
                      ),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentDetailsScreen(
                              mechanicName: mechanic?.name ?? 'John Mechanic',
                              serviceName: selectedSubService ?? 'Service',
                              location:
                                  '${customerLocation.latitude.toStringAsFixed(4)}, ${customerLocation.longitude.toStringAsFixed(4)}',
                              amount: 500.00,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Proceed to Pay',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize14,
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

class _EmergencyBottomPanel extends StatefulWidget {
  final Function(String) onEmergencyServiceSelected;
  final VoidCallback onCancel;

  const _EmergencyBottomPanel({
    required this.onEmergencyServiceSelected,
    required this.onCancel,
  });

  @override
  State<_EmergencyBottomPanel> createState() => _EmergencyBottomPanelState();
}

class _EmergencyBottomPanelState extends State<_EmergencyBottomPanel>
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
                        ? () {
                            widget.onEmergencyServiceSelected(
                              _selectedEmergency!,
                            );
                          }
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

// Service Selection Bottom Panel
class _ServiceSelectionBottomPanel extends StatefulWidget {
  final String? selectedService;
  final Function(String) onServiceSelected;
  final VoidCallback onBack;

  const _ServiceSelectionBottomPanel({
    required this.selectedService,
    required this.onServiceSelected,
    required this.onBack,
  });

  @override
  State<_ServiceSelectionBottomPanel> createState() =>
      _ServiceSelectionBottomPanelState();
}

class _ServiceSelectionBottomPanelState
    extends State<_ServiceSelectionBottomPanel>
    with SingleTickerProviderStateMixin {
  String? _currentSelection;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const List<Map<String, dynamic>> _services = [
    {
      'title': 'Tire Problem',
      'subtitle': 'Flat, busted, or damaged tires? We\'ve got you covered.',
      'icon': LucideIcons.disc_3,
      'color': AppTheme.emergencyColor,
      'bgColor': AppTheme.emergencyBg,
    },
    {
      'title': 'Brake Problem',
      'subtitle':
          'Squeaky or unresponsive brakes? Stay safe with expert fixes.',
      'icon': LucideIcons.triangle_alert,
      'color': AppTheme.warningColor,
      'bgColor': AppTheme.warningBg,
    },
    {
      'title': 'Engine Problems',
      'subtitle': 'Engine not running smoothly? Let us diagnose and repair it.',
      'icon': LucideIcons.wrench,
      'color': AppTheme.infoColor,
      'bgColor': AppTheme.infoBg,
    },
    {
      'title': 'Other Car Problems',
      'subtitle': 'For any other car troubles, we\'re here to help!',
      'icon': LucideIcons.settings,
      'color': AppTheme.successColor,
      'bgColor': AppTheme.successBg,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedService;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) => FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 14, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: const Icon(
                          LucideIcons.chevron_left,
                          size: 20,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What service do you need?',
                            style: AppTheme.figtreeExtraBold.copyWith(
                              fontSize: AppTheme.fontSize20,
                              color: AppTheme.onSurfaceColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Select a service type to continue',
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize13,
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Services list
              Flexible(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: _services.asMap().entries.map((entry) {
                    final index = entry.key;
                    final service = entry.value;
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 250 + (index * 80)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      ),
                      child: _buildServiceCard(
                        title: service['title']! as String,
                        subtitle: service['subtitle']! as String,
                        icon: service['icon']! as IconData,
                        color: service['color']! as Color,
                        bgColor: service['bgColor']! as Color,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentSelection != null
                          ? AppTheme.primaryColor
                          : AppTheme.borderColor,
                      foregroundColor: _currentSelection != null
                          ? AppTheme.onPrimaryColor
                          : AppTheme.subtitleColor,
                      disabledBackgroundColor: AppTheme.borderColor,
                      disabledForegroundColor: AppTheme.subtitleColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _currentSelection != null
                        ? () => widget.onServiceSelected(_currentSelection!)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: AppTheme.figtreeSemiBold.copyWith(
                            fontSize: AppTheme.fontSize16,
                            color: _currentSelection != null
                                ? Colors.white
                                : AppTheme.subtitleColor,
                          ),
                        ),
                        if (_currentSelection != null) ...[
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.arrow_right, size: 18),
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

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final bool isSelected = _currentSelection == title;
    return GestureDetector(
      onTap: () => setState(() => _currentSelection = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primarySurface
              : bgColor.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Left color accent strip
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected ? AppTheme.primaryColor : color,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTheme.figtreeSemiBold.copyWith(
                            fontSize: AppTheme.fontSize15,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTheme.figtreeRegular.copyWith(
                      fontSize: AppTheme.fontSize12,
                      color: AppTheme.subtitleColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-Service Selection Bottom Panel
class _SubServiceSelectionBottomPanel extends StatefulWidget {
  final String selectedService;
  final Function(String) onSubServiceSelected;
  final VoidCallback onBack;

  const _SubServiceSelectionBottomPanel({
    required this.selectedService,
    required this.onSubServiceSelected,
    required this.onBack,
  });

  @override
  State<_SubServiceSelectionBottomPanel> createState() =>
      _SubServiceSelectionBottomPanelState();
}

class _SubServiceSelectionBottomPanelState
    extends State<_SubServiceSelectionBottomPanel>
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
          'color': AppTheme.emergencyColor,
          'bgColor': AppTheme.emergencyBg,
          'options': [
            {'name': 'Flat Tire', 'icon': LucideIcons.circle_alert},
            {'name': 'Tire Replacement', 'icon': LucideIcons.refresh_cw},
            {'name': 'Tire Repair', 'icon': LucideIcons.wrench},
            {'name': 'Tire Installation', 'icon': LucideIcons.plus},
          ],
        };
      case 'Brake Problem':
        return {
          'title': 'Brake Problem',
          'subtitle': 'Which brake service do you need?',
          'color': AppTheme.warningColor,
          'bgColor': AppTheme.warningBg,
          'options': [
            {'name': 'Brake Pad Replacement', 'icon': LucideIcons.layers},
            {'name': 'Brake Fluid Check', 'icon': LucideIcons.droplets},
            {'name': 'Brake Repair', 'icon': LucideIcons.wrench},
            {'name': 'Brake System Diagnosis', 'icon': LucideIcons.search},
          ],
        };
      case 'Engine Problems':
        return {
          'title': 'Engine Problems',
          'subtitle': 'What engine service do you require?',
          'color': AppTheme.infoColor,
          'bgColor': AppTheme.infoBg,
          'options': [
            {'name': 'Engine Diagnosis', 'icon': LucideIcons.activity},
            {'name': 'Oil Change', 'icon': LucideIcons.droplet},
            {'name': 'Engine Repair', 'icon': LucideIcons.wrench},
            {'name': 'Engine Tune-up', 'icon': LucideIcons.sliders_horizontal},
          ],
        };
      case 'Other Car Problems':
        return {
          'title': 'Other Car Problems',
          'subtitle': 'Select the service you need',
          'color': AppTheme.successColor,
          'bgColor': AppTheme.successBg,
          'options': [
            {'name': 'Battery Issue', 'icon': LucideIcons.zap},
            {'name': 'AC Problem', 'icon': LucideIcons.thermometer},
            {'name': 'Electrical Issue', 'icon': LucideIcons.zap},
            {'name': 'General Inspection', 'icon': LucideIcons.clipboard_list},
          ],
        };
      default:
        return {
          'title': 'Select Service',
          'subtitle': 'Choose a sub-service',
          'color': AppTheme.subtitleColor,
          'bgColor': AppTheme.surfaceColor,
          'options': <Map<String, dynamic>>[],
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
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 14, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: const Icon(
                          LucideIcons.chevron_left,
                          size: 20,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceData['title'] as String,
                            style: AppTheme.figtreeExtraBold.copyWith(
                              fontSize: AppTheme.fontSize20,
                              color: AppTheme.onSurfaceColor,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            serviceData['subtitle'] as String,
                            style: AppTheme.figtreeRegular.copyWith(
                              fontSize: AppTheme.fontSize13,
                              color: AppTheme.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Options list
              Flexible(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                              child: _buildOptionCard(
                                option['name']! as String,
                                option['icon']! as IconData,
                                serviceData['color'] as Color,
                                serviceData['bgColor'] as Color,
                              ),
                            );
                          })
                          .toList(),
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOption != null
                          ? AppTheme.primaryColor
                          : AppTheme.borderColor,
                      foregroundColor: _selectedOption != null
                          ? AppTheme.onPrimaryColor
                          : AppTheme.subtitleColor,
                      disabledBackgroundColor: AppTheme.borderColor,
                      disabledForegroundColor: AppTheme.subtitleColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _selectedOption != null
                        ? () => widget.onSubServiceSelected(_selectedOption!)
                        : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Service',
                          style: AppTheme.figtreeSemiBold.copyWith(
                            fontSize: AppTheme.fontSize16,
                            color: _selectedOption != null
                                ? Colors.white
                                : AppTheme.subtitleColor,
                          ),
                        ),
                        if (_selectedOption != null) ...[
                          const SizedBox(width: 8),
                          const Icon(LucideIcons.arrow_right, size: 18),
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

  Widget _buildOptionCard(
    String name,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    final bool isSelected = _selectedOption == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primarySurface
              : bgColor.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Left accent strip
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),

            // Icon + name
            Expanded(
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? AppTheme.primaryColor : color,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTheme.figtreeSemiBold.copyWith(
                        fontSize: AppTheme.fontSize15,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
