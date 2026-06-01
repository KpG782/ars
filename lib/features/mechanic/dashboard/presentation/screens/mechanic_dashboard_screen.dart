/// Mechanic Dashboard Screen (Refactored)
///
/// Main dashboard screen for mechanics using modular components.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

import '../../domain/models/mechanic_status.dart';
import '../../domain/models/service_request.dart';
import '../controllers/mechanic_dashboard_controller.dart';
import '../widgets/active_job_panel.dart';
import '../widgets/mechanic_dashboard_dialogs.dart';
import '../widgets/mechanic_dashboard_top_bar.dart';
import '../widgets/mechanic_map_widget.dart';
import '../widgets/nearby_requests_panel.dart';
import '../widgets/online_status_button.dart';
import '../widgets/service_request_details_sheet.dart';

class MechanicDashboardScreen extends ConsumerStatefulWidget {
  const MechanicDashboardScreen({super.key});

  @override
  ConsumerState<MechanicDashboardScreen> createState() =>
      _MechanicDashboardScreenState();
}

class _MechanicDashboardScreenState
    extends ConsumerState<MechanicDashboardScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    Future.microtask(
      () => ref.read(mechanicDashboardControllerProvider.notifier).initialize(),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mechanicDashboardControllerProvider);
    final controller = ref.read(mechanicDashboardControllerProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          MechanicMapWidget(
            mapController: _mapController,
            currentPosition: state.currentPosition,
            mechanicStatus: state.mechanicStatus,
            nearbyRequests: state.nearbyRequests,
            acceptedRequest: state.acceptedRequest,
            routePoints: state.routePoints,
            onRequestTap: _onRequestTap,
          ),
          if (state.isInitialLoading) _buildLoadingOverlay(),
          MechanicDashboardTopBar(
            status: state.mechanicStatus,
            isOnline: state.isOnline,
            mechanicName: _getMechanicName(),
            onMenuTap: _openDrawer,
            onNotificationTap: _openNotifications,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomPanel(state, controller),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 16,
            child: OnlineStatusButton(
              status: state.mechanicStatus,
              isOnline: state.isOnline,
              onToggle: _onToggleOnlineStatus,
            ),
          ),
          Positioned(
            right: 16,
            bottom: _getRecenterButtonBottom(state),
            child: _buildRecenterButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.9),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              'Loading dashboard...',
              style: TextStyle(
                fontSize: AppTheme.fontSize16,
                color: AppTheme.subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(
    MechanicDashboardState state,
    MechanicDashboardController controller,
  ) {
    if (state.acceptedRequest != null &&
        (state.mechanicStatus == MechanicStatus.enRoute ||
            state.mechanicStatus == MechanicStatus.working)) {
      return ActiveJobPanel(
        request: state.acceptedRequest!,
        status: state.mechanicStatus,
        etaText: state.etaText,
        distanceText: state.distanceText,
        onViewDetails: () => _showRequestDetails(state.acceptedRequest!),
        onCall: _callCustomer,
        onNavigate: _openNavigation,
        onArrive: _onArrive,
        onComplete: _onCompleteService,
      );
    }

    if (state.isOnline && state.mechanicStatus == MechanicStatus.available) {
      return NearbyRequestsPanel(
        requests: state.nearbyRequests,
        isLoading: state.isLoadingRequests,
        onRefresh: () => controller.loadNearbyRequests(),
        onRequestTap: _onRequestTap,
      );
    }

    return _buildOfflinePanel();
  }

  Widget _buildOfflinePanel() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.wifi_off, size: 48, color: AppTheme.grey400),
          const SizedBox(height: 12),
          const Text(
            'You\'re Offline',
            style: TextStyle(
              fontSize: AppTheme.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Go online to start receiving service requests',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSize14,
              color: AppTheme.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecenterButton() {
    return GestureDetector(
      onTap: _recenterMap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.my_location,
          color: AppTheme.primaryColor,
          size: 24,
        ),
      ),
    );
  }

  double _getRecenterButtonBottom(MechanicDashboardState state) {
    if (state.acceptedRequest != null) {
      return 200;
    }
    if (state.isOnline && state.mechanicStatus == MechanicStatus.available) {
      return MediaQuery.of(context).size.height * 0.38;
    }
    return 180;
  }

  void _onToggleOnlineStatus() async {
    final state = ref.read(mechanicDashboardControllerProvider);
    final controller = ref.read(mechanicDashboardControllerProvider.notifier);

    if (state.isOnline) {
      if (!controller.canToggleOffline()) {
        await MechanicDashboardDialogs.showCannotGoOfflineDialog(
          context,
          state.mechanicStatus,
        );
        return;
      }

      final confirmed =
          await MechanicDashboardDialogs.showGoOfflineConfirmation(context);
      if (confirmed) {
        await controller.toggleOnlineStatus();
        _showToast('You are now offline');
      }
    } else {
      final confirmed = await MechanicDashboardDialogs.showGoOnlineConfirmation(
        context,
      );
      if (confirmed) {
        await controller.toggleOnlineStatus();
        _showToast('You are now online!');
      }
    }
  }

  void _onRequestTap(ServiceRequest request) {
    _showRequestDetails(request);
  }

  void _showRequestDetails(ServiceRequest request) {
    final state = ref.read(mechanicDashboardControllerProvider);

    ServiceRequestDetailsSheet.show(
      context,
      request: request,
      etaText: state.etaText,
      distanceText: state.distanceText,
      isEnRoute: state.mechanicStatus == MechanicStatus.enRoute,
      isWorking: state.mechanicStatus == MechanicStatus.working,
      onAccept: () => _onAcceptRequest(request),
      onArrive: _onArrive,
      onComplete: _onCompleteService,
      onCall: _callCustomer,
      onMessage: _messageCustomer,
    );
  }

  void _onAcceptRequest(ServiceRequest request) async {
    await ref
        .read(mechanicDashboardControllerProvider.notifier)
        .acceptRequest(request);
    _showToast('Request accepted! Navigating to customer...');
    _animateToRoute();
  }

  void _onArrive() async {
    final confirmed = await MechanicDashboardDialogs.showArriveConfirmation(
      context,
    );
    if (confirmed) {
      ref
          .read(mechanicDashboardControllerProvider.notifier)
          .updateStatus(MechanicStatus.working);
      _showToast('Arrival confirmed. Start working!');
    }
  }

  void _onCompleteService() async {
    final request = ref
        .read(mechanicDashboardControllerProvider)
        .acceptedRequest;
    if (request == null) {
      return;
    }

    final earnings =
        request.estimatedPrice - request.discountApplied + request.tipAmount;

    await MechanicDashboardDialogs.showServiceCompletedDialog(
      context,
      earnings: earnings,
      customerName: request.customerName,
    );

    final controller = ref.read(mechanicDashboardControllerProvider.notifier);
    controller.updateStatus(MechanicStatus.available);
    controller.loadNearbyRequests();
  }

  void _recenterMap() {
    final state = ref.read(mechanicDashboardControllerProvider);
    _mapController.move(state.currentPosition, 15.0);
  }

  void _animateToRoute() {
    final state = ref.read(mechanicDashboardControllerProvider);
    if (state.routePoints.length >= 2) {
      final bounds = LatLngBounds.fromPoints(state.routePoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
      );
    }
  }

  void _callCustomer() {
    _showToast('Calling customer...');
  }

  void _messageCustomer() {
    _showToast('Opening chat...');
  }

  void _openNavigation() {
    _showToast('Opening navigation...');
  }

  void _openDrawer() {
    _showToast('Menu coming soon');
  }

  void _openNotifications() {
    _showToast('Notifications coming soon');
  }

  String _getMechanicName() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'Mechanic';
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppTheme.onSurfaceColor,
      textColor: Colors.white,
    );
  }
}
