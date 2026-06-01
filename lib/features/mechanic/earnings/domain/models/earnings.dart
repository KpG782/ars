/// Domain Model: Earnings Summary
///
/// Represents mechanic earnings data in the business domain
library;

class EarningsSummary {
  final double totalEarnings;
  final double totalTips;
  final int totalServices;
  final double averageRating;
  final double platformFees;
  final double netEarnings;
  final DateTime periodStart;
  final DateTime periodEnd;

  EarningsSummary({
    required this.totalEarnings,
    required this.totalTips,
    required this.totalServices,
    required this.averageRating,
    required this.platformFees,
    required this.netEarnings,
    required this.periodStart,
    required this.periodEnd,
  });

  // Business logic: Calculate average per service
  double get averageEarningsPerService {
    if (totalServices == 0) return 0;
    return totalEarnings / totalServices;
  }

  // Business logic: Calculate tip percentage
  double get tipPercentage {
    if (totalEarnings == 0) return 0;
    return (totalTips / totalEarnings) * 100;
  }

  // Business logic: Check if withdrawal is possible
  bool get canWithdraw => totalEarnings >= 100;

  EarningsSummary copyWith({
    double? totalEarnings,
    double? totalTips,
    int? totalServices,
    double? averageRating,
    double? platformFees,
    double? netEarnings,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return EarningsSummary(
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalTips: totalTips ?? this.totalTips,
      totalServices: totalServices ?? this.totalServices,
      averageRating: averageRating ?? this.averageRating,
      platformFees: platformFees ?? this.platformFees,
      netEarnings: netEarnings ?? this.netEarnings,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }
}

/// Withdrawal request entity
class WithdrawalRequest {
  final String id;
  final String mechanicId;
  final double amount;
  final String paymentMethod;
  final String? accountDetails;
  final DateTime requestDate;
  final WithdrawalStatus status;
  final DateTime? processedDate;

  WithdrawalRequest({
    required this.id,
    required this.mechanicId,
    required this.amount,
    required this.paymentMethod,
    this.accountDetails,
    required this.requestDate,
    this.status = WithdrawalStatus.pending,
    this.processedDate,
  });

  WithdrawalRequest copyWith({
    String? id,
    String? mechanicId,
    double? amount,
    String? paymentMethod,
    String? accountDetails,
    DateTime? requestDate,
    WithdrawalStatus? status,
    DateTime? processedDate,
  }) {
    return WithdrawalRequest(
      id: id ?? this.id,
      mechanicId: mechanicId ?? this.mechanicId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountDetails: accountDetails ?? this.accountDetails,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      processedDate: processedDate ?? this.processedDate,
    );
  }
}

/// Withdrawal status enum
enum WithdrawalStatus { pending, processing, completed, failed, cancelled }

/// Earnings period filter
enum EarningsPeriod { weekly, monthly, allTime }
