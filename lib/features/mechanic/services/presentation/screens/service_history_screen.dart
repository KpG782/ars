import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import '../../../dashboard/domain/models/service_request.dart';
import '../../domain/repositories/service_history_repository.dart';
import '../../data/repositories/firebase_service_history_repository.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  ServiceHistoryFilter _selectedFilter = ServiceHistoryFilter.all;

  // Repository (Dependency Injection)
  late final ServiceHistoryRepository _historyRepository;

  @override
  void initState() {
    super.initState();
    // Initialize repository (in production, use dependency injection)
    _historyRepository = FirebaseServiceHistoryRepository();
  }

  String get _mechanicId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    final mechanicId = _mechanicId;

    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: Text(
          'Service History',
          style: AppTheme.figtreeBold.copyWith(
            color: AppTheme.onSurfaceColor,
            fontSize: AppTheme.fontSize18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.onSurfaceColor,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<List<ServiceRequest>>(
              stream: _historyRepository.getServiceHistory(
                mechanicId: mechanicId,
                filter: _selectedFilter,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final services = snapshot.data ?? [];

                if (services.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(services[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('All', ServiceHistoryFilter.all),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', ServiceHistoryFilter.completed),
          const SizedBox(width: 8),
          _buildFilterChip('Cancelled', ServiceHistoryFilter.cancelled),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ServiceHistoryFilter value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppTheme.grey200,
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.grey700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildServiceCard(ServiceRequest service) {
    final isCompleted = service.status == RequestStatus.completed;
    final statusColor = isCompleted ? AppTheme.green : AppTheme.orange;
    final statusText = isCompleted ? 'Completed' : 'Cancelled';

    // Format location to display
    final locationText =
        'Lat: ${service.location.latitude.toStringAsFixed(4)}, '
        'Lng: ${service.location.longitude.toStringAsFixed(4)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.serviceType,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: AppTheme.fontSize12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.user, size: 16, color: AppTheme.grey),
                  const SizedBox(width: 4),
                  Text(
                    service.customerName,
                    style: const TextStyle(
                      color: AppTheme.grey700,
                      fontSize: AppTheme.fontSize14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    LucideIcons.map_pin,
                    size: 16,
                    color: AppTheme.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      locationText,
                      style: const TextStyle(
                        color: AppTheme.grey700,
                        fontSize: AppTheme.fontSize14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(LucideIcons.clock, size: 16, color: AppTheme.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(service.requestTime),
                    style: const TextStyle(
                      color: AppTheme.grey700,
                      fontSize: AppTheme.fontSize14,
                    ),
                  ),
                ],
              ),
              if (isCompleted) ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Earnings',
                          style: TextStyle(
                            color: AppTheme.grey600,
                            fontSize: AppTheme.fontSize12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₱${service.mechanicEarnings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSize18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (service.customerRating != null)
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.star,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.customerRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.history, size: 80, color: AppTheme.grey300),
          SizedBox(height: 16),
          Text(
            'No service history',
            style: TextStyle(
              fontSize: AppTheme.fontSize18,
              color: AppTheme.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Completed services will appear here',
            style: TextStyle(
              fontSize: AppTheme.fontSize14,
              color: AppTheme.grey500,
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDetails(ServiceRequest service) {
    // Format location to display
    final locationText =
        'Lat: ${service.location.latitude.toStringAsFixed(4)}, '
        'Lng: ${service.location.longitude.toStringAsFixed(4)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceType,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Service ID: ${service.id}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize14,
                        color: AppTheme.grey600,
                      ),
                    ),
                    const Divider(height: 32),
                    _buildDetailRow(
                      'Customer',
                      service.customerName,
                      LucideIcons.user,
                    ),
                    _buildDetailRow(
                      'Phone',
                      service.customerPhone ?? 'N/A',
                      LucideIcons.phone,
                    ),
                    _buildDetailRow(
                      'Location',
                      locationText,
                      LucideIcons.map_pin,
                    ),
                    _buildDetailRow(
                      'Date',
                      _formatDate(service.requestTime),
                      LucideIcons.calendar,
                    ),
                    if (service.status == RequestStatus.completed) ...[
                      _buildDetailRow(
                        'Duration',
                        service.formattedDuration,
                        LucideIcons.timer,
                      ),
                      const Divider(height: 32),
                      _buildDetailRow(
                        'Service Fee',
                        '₱${service.actualPrice?.toStringAsFixed(2)}',
                        LucideIcons.circle_dollar_sign,
                      ),
                      if (service.tipAmount > 0)
                        _buildDetailRow(
                          'Tip',
                          '₱${service.tipAmount.toStringAsFixed(2)}',
                          LucideIcons.star,
                        ),
                      _buildDetailRow(
                        'Your Earnings',
                        '₱${service.mechanicEarnings.toStringAsFixed(2)}',
                        LucideIcons.wallet,
                        valueColor: AppTheme.primaryColor,
                      ),
                      if (service.customerRating != null) ...[
                        const Divider(height: 32),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.star,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rating: ${service.customerRating?.toStringAsFixed(1) ?? 'N/A'}/5.0',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSize16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (service.customerReview != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    service.customerReview!,
                                    style: const TextStyle(
                                      fontSize: AppTheme.fontSize14,
                                      color: AppTheme.grey700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                    if (service.status == RequestStatus.cancelled) ...[
                      const Divider(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            LucideIcons.circle_x,
                            color: AppTheme.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cancellation Reason',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontSize16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  service.cancellationReason ??
                                      'No reason provided',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSize14,
                                    color: AppTheme.grey700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.grey600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize12,
                    color: AppTheme.grey600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppTheme.fontSize16,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
