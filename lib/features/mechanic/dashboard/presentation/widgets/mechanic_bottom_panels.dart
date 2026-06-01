import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';
import 'mechanic_enums.dart';
import '../../domain/models/service_request.dart';
import 'service_request_card.dart';
import '../screens/payment_confirmation_screen.dart';
import '../../../chat/presentation/screens/mechanic_chat_screen.dart';

class MechanicBottomPanels extends StatelessWidget {
  final MechanicStatus mechanicStatus;
  final List<ServiceRequest> nearbyRequests;
  final ServiceRequest? acceptedRequest;
  final bool isOnline;
  final Function(MechanicStatus) onStatusChanged;
  final Function(ServiceRequest) onRequestAccepted;
  final VoidCallback onToggleOnline;
  final String etaText;
  final String distanceText;

  const MechanicBottomPanels({
    super.key,
    required this.mechanicStatus,
    required this.nearbyRequests,
    required this.acceptedRequest,
    required this.isOnline,
    required this.onStatusChanged,
    required this.onRequestAccepted,
    required this.onToggleOnline,
    this.etaText = '15 minutes',
    this.distanceText = '0 km',
  });

  @override
  Widget build(BuildContext context) {
    switch (mechanicStatus) {
      case MechanicStatus.offline:
        return _OfflinePanel(onToggleOnline: onToggleOnline);
      case MechanicStatus.available:
        return _AvailablePanel(
          nearbyRequests: nearbyRequests,
          onRequestAccepted: onRequestAccepted,
        );
      case MechanicStatus.enRoute:
        return _EnRoutePanel(
          acceptedRequest: acceptedRequest!,
          onStatusChanged: onStatusChanged,
          etaText: etaText,
          distanceText: distanceText,
        );
      case MechanicStatus.working:
        return _WorkingPanel(
          acceptedRequest: acceptedRequest!,
          onStatusChanged: onStatusChanged,
        );
      case MechanicStatus.completed:
        return _CompletedPanel(
          acceptedRequest: acceptedRequest!,
          onStatusChanged: onStatusChanged,
        );
    }
  }
}

class _OfflinePanel extends StatelessWidget {
  final VoidCallback onToggleOnline;

  const _OfflinePanel({required this.onToggleOnline});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.grey100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.grey400.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  LucideIcons.circle_off,
                  size: 40,
                  color: AppTheme.grey500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You\'re Currently Offline',
                style: AppTheme.figtreeExtraBold.copyWith(
                  fontSize: AppTheme.fontSize20,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Go online to start receiving service requests from customers in your area.',
                style: AppTheme.figtreeRegular.copyWith(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: onToggleOnline,
                  child: Text(
                    'Go Online',
                    style: AppTheme.figtreeSemiBold.copyWith(
                      fontSize: AppTheme.fontSize16,
                      color: Colors.white,
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

class _AvailablePanel extends StatelessWidget {
  final List<ServiceRequest> nearbyRequests;
  final Function(ServiceRequest) onRequestAccepted;

  const _AvailablePanel({
    required this.nearbyRequests,
    required this.onRequestAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.radio,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Available for Requests',
                    style: AppTheme.figtreeExtraBold.copyWith(
                      fontSize: AppTheme.fontSize18,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${nearbyRequests.length} requests',
                      style: AppTheme.figtreeSemiBold.copyWith(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: nearbyRequests.isEmpty
                  ? SingleChildScrollView(
                      controller: scrollController,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.search,
                                size: 60,
                                color: AppTheme.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No requests nearby',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize16,
                                  color: AppTheme.grey,
                                ),
                              ),
                              Text(
                                'Stay online to receive new requests',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize12,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: nearbyRequests.length,
                      itemBuilder: (context, index) {
                        return ServiceRequestCard(
                          request: nearbyRequests[index],
                          onAccept: () =>
                              onRequestAccepted(nearbyRequests[index]),
                          onReject: () {
                            ToastHelper.showInfo(
                              context,
                              'Request declined',
                              duration: const Duration(seconds: 2),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnRoutePanel extends StatelessWidget {
  final ServiceRequest acceptedRequest;
  final Function(MechanicStatus) onStatusChanged;
  final String etaText;
  final String distanceText;

  const _EnRoutePanel({
    required this.acceptedRequest,
    required this.onStatusChanged,
    this.etaText = '15 minutes',
    this.distanceText = '0 km',
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
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

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.warningBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.navigation,
                            color: AppTheme.warningColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'En Route to Customer',
                          style: AppTheme.figtreeExtraBold.copyWith(
                            fontSize: AppTheme.fontSize18,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warningBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.warningColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'On the way',
                                style: AppTheme.figtreeSemiBold.copyWith(
                                  fontSize: AppTheme.fontSize11,
                                  color: AppTheme.warningColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Customer info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.orange50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppTheme.warningBg,
                            child: Icon(
                              LucideIcons.user,
                              color: AppTheme.warningColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acceptedRequest.customerName,
                                  style: AppTheme.figtreeSemiBold.copyWith(
                                    fontSize: AppTheme.fontSize15,
                                    color: AppTheme.onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  acceptedRequest.serviceType,
                                  style: AppTheme.figtreeRegular.copyWith(
                                    fontSize: AppTheme.fontSize12,
                                    color: AppTheme.subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const IconButton(
                            onPressed: null,
                            icon: Icon(
                              LucideIcons.phone,
                              color: AppTheme.warningColor,
                              size: 20,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MechanicChatScreen(
                                    serviceRequest: acceptedRequest,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              LucideIcons.message_circle,
                              color: AppTheme.warningColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ETA / Distance
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.orange50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.clock,
                                      color: AppTheme.warningColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        etaText,
                                        style: AppTheme.figtreeSemiBold
                                            .copyWith(
                                              fontSize: AppTheme.fontSize14,
                                              color: AppTheme.orange700,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.map_pin,
                                      color: AppTheme.warningColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        distanceText,
                                        style: AppTheme.figtreeSemiBold
                                            .copyWith(
                                              fontSize: AppTheme.fontSize14,
                                              color: AppTheme.orange700,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                DraggableScrollableActuator.reset(context);
                                ToastHelper.showInfo(
                                  context,
                                  'Navigation started - Following your route',
                                  duration: const Duration(seconds: 3),
                                );
                              },
                              icon: const Icon(
                                LucideIcons.navigation,
                                size: 18,
                              ),
                              label: Text(
                                'Start Navigation',
                                style: AppTheme.figtreeSemiBold.copyWith(
                                  fontSize: AppTheme.fontSize14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.warningColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Live location badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.orange50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.warningColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.map_pin,
                            color: AppTheme.warningColor,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Live location shared with customer',
                              style: AppTheme.figtreeSemiBold.copyWith(
                                fontSize: AppTheme.fontSize13,
                                color: AppTheme.orange700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Active',
                                  style: AppTheme.figtreeSemiBold.copyWith(
                                    fontSize: AppTheme.fontSize11,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => _showStartServiceConfirmation(context),
                        child: Text(
                          'Arrived — Start Service',
                          style: AppTheme.figtreeSemiBold.copyWith(
                            fontSize: AppTheme.fontSize16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartServiceConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.wrench,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Start Service?',
                style: AppTheme.figtreeExtraBold.copyWith(
                  fontSize: AppTheme.fontSize18,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please confirm you have:',
              style: AppTheme.figtreeSemiBold.copyWith(
                fontSize: AppTheme.fontSize15,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildChecklistItem('Arrived at customer location'),
            _buildChecklistItem('Met with the customer'),
            _buildChecklistItem('Inspected the vehicle issue'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.timer,
                    color: AppTheme.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Service timer will start now',
                      style: AppTheme.figtreeRegular.copyWith(
                        fontSize: AppTheme.fontSize13,
                        color: AppTheme.orange700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Not Yet',
              style: AppTheme.figtreeRegular.copyWith(
                color: AppTheme.subtitleColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onStatusChanged(MechanicStatus.working);
              ToastHelper.showWarning(
                context,
                'Service started - Timer running',
                duration: const Duration(seconds: 2),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              'Start Service',
              style: AppTheme.figtreeSemiBold.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            LucideIcons.circle_check,
            color: AppTheme.warningColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.figtreeRegular.copyWith(
                fontSize: AppTheme.fontSize14,
                color: AppTheme.onSurfaceColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkingPanel extends StatefulWidget {
  final ServiceRequest acceptedRequest;
  final Function(MechanicStatus) onStatusChanged;

  const _WorkingPanel({
    required this.acceptedRequest,
    required this.onStatusChanged,
  });

  @override
  State<_WorkingPanel> createState() => _WorkingPanelState();
}

class _WorkingPanelState extends State<_WorkingPanel> {
  late DateTime _startTime;
  Duration _elapsedTime = Duration.zero;
  late Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _timerStream = Stream.periodic(
      const Duration(seconds: 1),
      (count) => count,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.infoBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.wrench,
                      color: AppTheme.infoColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Working on Service',
                    style: AppTheme.figtreeExtraBold.copyWith(
                      fontSize: AppTheme.fontSize18,
                      color: AppTheme.onSurfaceColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Timer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.infoBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.infoColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.timer,
                      color: AppTheme.infoColor,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    StreamBuilder<int>(
                      stream: _timerStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _elapsedTime = DateTime.now().difference(_startTime);
                          final hours = _elapsedTime.inHours.toString().padLeft(
                            2,
                            '0',
                          );
                          final minutes = (_elapsedTime.inMinutes % 60)
                              .toString()
                              .padLeft(2, '0');
                          final seconds = (_elapsedTime.inSeconds % 60)
                              .toString()
                              .padLeft(2, '0');
                          return Column(
                            children: [
                              Text(
                                'Time Working',
                                style: AppTheme.figtreeRegular.copyWith(
                                  fontSize: AppTheme.fontSize11,
                                  color: AppTheme.subtitleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$hours:$minutes:$seconds',
                                style: AppTheme.figtreeExtraBold.copyWith(
                                  fontSize: AppTheme.fontSize28,
                                  color: AppTheme.infoTx,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return Text(
                          '00:00:00',
                          style: AppTheme.figtreeExtraBold.copyWith(
                            fontSize: AppTheme.fontSize28,
                            color: AppTheme.infoTx,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.infoBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.infoColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.wrench,
                          size: 14,
                          color: AppTheme.infoColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.acceptedRequest.serviceType,
                          style: AppTheme.figtreeSemiBold.copyWith(
                            fontSize: AppTheme.fontSize14,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.user,
                          size: 14,
                          color: AppTheme.subtitleColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.acceptedRequest.customerName,
                          style: AppTheme.figtreeRegular.copyWith(
                            fontSize: AppTheme.fontSize13,
                            color: AppTheme.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MechanicChatScreen(
                          serviceRequest: widget.acceptedRequest,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.message_circle, size: 18),
                  label: Text(
                    'Chat with Customer',
                    style: AppTheme.figtreeSemiBold.copyWith(
                      fontSize: AppTheme.fontSize14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.infoColor,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    side: const BorderSide(
                      color: AppTheme.infoColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MechanicPaymentConfirmationScreen(
                          serviceRequest: widget.acceptedRequest,
                          onConfirm: () {
                            widget.onStatusChanged(MechanicStatus.available);
                          },
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Complete Service',
                    style: AppTheme.figtreeSemiBold.copyWith(
                      fontSize: AppTheme.fontSize16,
                      color: Colors.white,
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

class _CompletedPanel extends StatelessWidget {
  final ServiceRequest acceptedRequest;
  final Function(MechanicStatus) onStatusChanged;

  const _CompletedPanel({
    required this.acceptedRequest,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  LucideIcons.circle_check_big,
                  color: AppTheme.successColor,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Service Completed!',
                style: AppTheme.figtreeExtraBold.copyWith(
                  fontSize: AppTheme.fontSize22,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '₱${acceptedRequest.estimatedPrice.toStringAsFixed(2)} earned',
                  style: AppTheme.figtreeExtraBold.copyWith(
                    fontSize: AppTheme.fontSize18,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () => onStatusChanged(MechanicStatus.available),
                  child: Text(
                    'Back to Available',
                    style: AppTheme.figtreeSemiBold.copyWith(
                      fontSize: AppTheme.fontSize16,
                      color: Colors.white,
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
