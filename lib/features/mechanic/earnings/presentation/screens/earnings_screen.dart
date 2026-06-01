import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/utils/toast_helper.dart';
import '../../domain/models/earnings.dart';
import '../providers/earnings_providers.dart';
import '../../../dashboard/domain/models/service_request.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  String _selectedPaymentMethod = 'bank'; // bank, gcash, paypal

  @override
  void initState() {
    super.initState();
    // Kick off the first load once the widget is mounted.
    Future.microtask(
      () => ref.read(earningsControllerProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Surface load/withdrawal errors as a toast.
    ref.listen(earningsControllerProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ToastHelper.showError(context, next.errorMessage!);
      }
    });

    final state = ref.watch(earningsControllerProvider);
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Earnings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: AppTheme.fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppTheme.fontSize14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₱${state.totalEarnings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSize40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _BalanceStat(
                            label: 'Services',
                            value: '${state.totalServices.toInt()}',
                            icon: LucideIcons.wrench,
                          ),
                        ),
                        Expanded(
                          child: _BalanceStat(
                            label: 'Tips',
                            value: '₱${state.totalTips.toStringAsFixed(0)}',
                            icon: LucideIcons.heart,
                          ),
                        ),
                        Expanded(
                          child: _BalanceStat(
                            label: 'Rating',
                            value: '${state.averageRating.toStringAsFixed(1)}★',
                            icon: LucideIcons.star,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Withdrawal Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.wallet,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Withdrawal Method',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _PaymentMethodButton(
                      method: 'Bank Transfer',
                      icon: LucideIcons.building,
                      isSelected: _selectedPaymentMethod == 'bank',
                      onTap: () =>
                          setState(() => _selectedPaymentMethod = 'bank'),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodButton(
                      method: 'GCash',
                      icon: LucideIcons.smartphone,
                      isSelected: _selectedPaymentMethod == 'gcash',
                      onTap: () =>
                          setState(() => _selectedPaymentMethod = 'gcash'),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodButton(
                      method: 'PayMaya',
                      icon: LucideIcons.wallet,
                      isSelected: _selectedPaymentMethod == 'paypal',
                      onTap: () =>
                          setState(() => _selectedPaymentMethod = 'paypal'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.totalEarnings > 100
                            ? () => _showWithdrawalDialog()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: AppTheme.grey300,
                        ),
                        child: Text(
                          state.totalEarnings > 100
                              ? 'Withdraw ₱${state.totalEarnings.toStringAsFixed(2)}'
                              : 'Minimum ₱100 to withdraw',
                          style: TextStyle(
                            fontSize: AppTheme.fontSize16,
                            fontWeight: FontWeight.bold,
                            color: state.totalEarnings > 100
                                ? Colors.white
                                : AppTheme.grey600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Period Filter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Earnings History',
                    style: TextStyle(
                      fontSize: AppTheme.fontSize18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PopupMenuButton<EarningsPeriod>(
                    initialValue: state.period,
                    onSelected: (value) => ref
                        .read(earningsControllerProvider.notifier)
                        .selectPeriod(value),
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: EarningsPeriod.weekly,
                        child: Text('This Week'),
                      ),
                      const PopupMenuItem(
                        value: EarningsPeriod.monthly,
                        child: Text('This Month'),
                      ),
                      const PopupMenuItem(
                        value: EarningsPeriod.allTime,
                        child: Text('All Time'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.grey300),
                      ),
                      child: Row(
                        children: [
                          Text(
                            state.period == EarningsPeriod.weekly
                                ? 'This Week'
                                : state.period == EarningsPeriod.monthly
                                ? 'This Month'
                                : 'All Time',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSize13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.chevron_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Earnings List
              if (state.completedServices.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: const Column(
                    children: [
                      Icon(
                        LucideIcons.history,
                        size: 60,
                        color: AppTheme.grey300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No earnings yet',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          color: AppTheme.grey600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Complete services to see earnings',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize13,
                          color: AppTheme.grey400,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.completedServices.length,
                  itemBuilder: (context, index) {
                    final service = state.completedServices[index];
                    return _EarningsCard(service: service);
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawalDialog() {
    final state = ref.read(earningsControllerProvider);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                LucideIcons.circle_check,
                color: AppTheme.primaryColor,
                size: 28,
              ),
              SizedBox(width: 12),
              Text('Withdrawal Confirmed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount: ₱${state.totalEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Method: ${_selectedPaymentMethod.toUpperCase()}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: AppTheme.grey600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Processing time: 1-2 business days',
                style: TextStyle(
                  fontSize: AppTheme.fontSize13,
                  color: AppTheme.grey500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                // submitWithdrawal forwards to the repository and refreshes the
                // earnings state; errors are surfaced via ref.listen in build().
                final ok = await ref
                    .read(earningsControllerProvider.notifier)
                    .submitWithdrawal(
                      amount: state.totalEarnings,
                      paymentMethod: _selectedPaymentMethod,
                    );

                if (mounted && ok) {
                  ToastHelper.showSuccess(
                    context,
                    'Withdrawal request submitted!',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Confirm Withdrawal',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BalanceStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppTheme.fontSize16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: AppTheme.fontSize12,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final String method;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.method,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.grey600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  fontSize: AppTheme.fontSize15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.primaryColor : Colors.black87,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.grey400,
                  width: 2,
                ),
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(LucideIcons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final ServiceRequest service;

  const _EarningsCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.wrench, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.customerName,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  service.serviceType,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize13,
                    color: AppTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${service.mechanicEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSize16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              if (service.tipAmount > 0)
                Text(
                  '+₱${service.tipAmount.toStringAsFixed(2)} tip',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize12,
                    color: AppTheme.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
