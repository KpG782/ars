/// Repository Interfaces for Earnings
///
/// Defines contracts for earnings operations following the Repository Pattern
library;

import '../models/earnings.dart';
import '../../../dashboard/domain/models/service_request.dart';

/// Repository for managing mechanic earnings
abstract class EarningsRepository {
  /// Get earnings summary for a specific period
  Future<EarningsSummary> getEarningsSummary({
    required String mechanicId,
    required EarningsPeriod period,
  });

  /// Get completed service requests for earnings calculation
  Future<List<ServiceRequest>> getCompletedServices({
    required String mechanicId,
    required EarningsPeriod period,
  });

  /// Submit a withdrawal request
  Future<WithdrawalRequest> submitWithdrawalRequest({
    required String mechanicId,
    required double amount,
    required String paymentMethod,
    String? accountDetails,
  });

  /// Get withdrawal history
  Future<List<WithdrawalRequest>> getWithdrawalHistory({
    required String mechanicId,
    int limit = 20,
  });

  /// Get pending withdrawal requests
  Future<List<WithdrawalRequest>> getPendingWithdrawals(String mechanicId);

  /// Cancel a withdrawal request
  Future<void> cancelWithdrawal(String withdrawalId);
}

/// Custom exceptions for earnings operations
class EarningsException implements Exception {
  final String message;
  final EarningsErrorCode code;

  EarningsException(this.message, this.code);

  @override
  String toString() => 'EarningsException: $message (${code.name})';
}

/// Error codes for earnings operations
enum EarningsErrorCode {
  insufficientBalance,
  withdrawalFailed,
  invalidAmount,
  networkError,
  notFound,
  unknown,
}
