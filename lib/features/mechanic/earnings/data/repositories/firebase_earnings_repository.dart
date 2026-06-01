/// Firebase Implementation of EarningsRepository
///
/// Provides Firebase Firestore implementation for earnings operations
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/models/earnings.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../../../dashboard/domain/models/service_request.dart';

class FirebaseEarningsRepository implements EarningsRepository {
  final FirebaseFirestore _firestore;

  FirebaseEarningsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<EarningsSummary> getEarningsSummary({
    required String mechanicId,
    required EarningsPeriod period,
  }) async {
    try {
      final services = await getCompletedServices(
        mechanicId: mechanicId,
        period: period,
      );

      if (services.isEmpty) {
        final dates = _getPeriodDates(period);
        return EarningsSummary(
          totalEarnings: 0,
          totalTips: 0,
          totalServices: 0,
          averageRating: 0,
          platformFees: 0,
          netEarnings: 0,
          periodStart: dates.$1,
          periodEnd: dates.$2,
        );
      }

      final totalEarnings = services.fold<double>(
        0,
        (total, service) => total + service.mechanicEarnings,
      );

      final totalTips = services.fold<double>(
        0,
        (total, service) => total + service.tipAmount,
      );

      final platformFees = services.fold<double>(
        0,
        (total, service) => total + service.platformFee,
      );

      final totalRating = services.fold<double>(
        0,
        (total, service) => total + (service.customerRating ?? 0),
      );

      final servicesWithRating = services
          .where((s) => s.customerRating != null)
          .length;

      final dates = _getPeriodDates(period);

      return EarningsSummary(
        totalEarnings: totalEarnings,
        totalTips: totalTips,
        totalServices: services.length,
        averageRating: servicesWithRating > 0
            ? totalRating / servicesWithRating
            : 0,
        platformFees: platformFees,
        netEarnings: totalEarnings,
        periodStart: dates.$1,
        periodEnd: dates.$2,
      );
    } catch (e) {
      throw EarningsException(
        'Failed to get earnings summary: $e',
        EarningsErrorCode.networkError,
      );
    }
  }

  @override
  Future<List<ServiceRequest>> getCompletedServices({
    required String mechanicId,
    required EarningsPeriod period,
  }) async {
    try {
      final dates = _getPeriodDates(period);

      var query = _firestore
          .collection('service_requests')
          .where('mechanicId', isEqualTo: mechanicId)
          .where('status', isEqualTo: 'completed')
          .where('completionTime', isGreaterThanOrEqualTo: dates.$1)
          .where('completionTime', isLessThanOrEqualTo: dates.$2)
          .orderBy('completionTime', descending: true);

      final snapshot = await query.get();

      return snapshot.docs.map((doc) => _mapDocToServiceRequest(doc)).toList();
    } catch (e) {
      throw EarningsException(
        'Failed to get completed services: $e',
        EarningsErrorCode.networkError,
      );
    }
  }

  @override
  Future<WithdrawalRequest> submitWithdrawalRequest({
    required String mechanicId,
    required double amount,
    required String paymentMethod,
    String? accountDetails,
  }) async {
    try {
      if (amount < 100) {
        throw EarningsException(
          'Minimum withdrawal amount is ₱100',
          EarningsErrorCode.invalidAmount,
        );
      }

      final docRef = _firestore.collection('withdrawal_requests').doc();

      final withdrawal = WithdrawalRequest(
        id: docRef.id,
        mechanicId: mechanicId,
        amount: amount,
        paymentMethod: paymentMethod,
        accountDetails: accountDetails,
        requestDate: DateTime.now(),
        status: WithdrawalStatus.pending,
      );

      await docRef.set({
        'mechanicId': mechanicId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'accountDetails': accountDetails,
        'requestDate': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      return withdrawal;
    } on EarningsException {
      rethrow;
    } catch (e) {
      throw EarningsException(
        'Failed to submit withdrawal: $e',
        EarningsErrorCode.withdrawalFailed,
      );
    }
  }

  @override
  Future<List<WithdrawalRequest>> getWithdrawalHistory({
    required String mechanicId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('withdrawal_requests')
          .where('mechanicId', isEqualTo: mechanicId)
          .orderBy('requestDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => _mapDocToWithdrawal(doc)).toList();
    } catch (e) {
      throw EarningsException(
        'Failed to get withdrawal history: $e',
        EarningsErrorCode.networkError,
      );
    }
  }

  @override
  Future<List<WithdrawalRequest>> getPendingWithdrawals(
    String mechanicId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('withdrawal_requests')
          .where('mechanicId', isEqualTo: mechanicId)
          .where('status', isEqualTo: 'pending')
          .orderBy('requestDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => _mapDocToWithdrawal(doc)).toList();
    } catch (e) {
      throw EarningsException(
        'Failed to get pending withdrawals: $e',
        EarningsErrorCode.networkError,
      );
    }
  }

  @override
  Future<void> cancelWithdrawal(String withdrawalId) async {
    try {
      await _firestore
          .collection('withdrawal_requests')
          .doc(withdrawalId)
          .update({
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw EarningsException(
        'Failed to cancel withdrawal: $e',
        EarningsErrorCode.withdrawalFailed,
      );
    }
  }

  // Helper: Get period date range
  (DateTime, DateTime) _getPeriodDates(EarningsPeriod period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (period) {
      case EarningsPeriod.weekly:
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case EarningsPeriod.monthly:
        start = DateTime(now.year, now.month, 1);
        break;
      case EarningsPeriod.allTime:
        start = DateTime(2020, 1, 1); // App launch date
        break;
    }

    return (start, end);
  }

  // Helper: Map Firestore doc to ServiceRequest
  ServiceRequest _mapDocToServiceRequest(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final geoPoint = data['location'] as GeoPoint;

    return ServiceRequest(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      location: LatLng(geoPoint.latitude, geoPoint.longitude),
      serviceType: data['serviceType'] ?? '',
      description: data['description'] ?? '',
      estimatedPrice: (data['estimatedPrice'] ?? 0).toDouble(),
      actualPrice: data['actualPrice']?.toDouble(),
      requestTime: (data['requestTime'] as Timestamp).toDate(),
      completionTime: data['completionTime'] != null
          ? (data['completionTime'] as Timestamp).toDate()
          : null,
      status: _parseRequestStatus(data['status']),
      customerPhone: data['customerPhone'],
      customerPhoto: data['customerPhoto'],
      tipAmount: (data['tipAmount'] ?? 0).toDouble(),
      appliedPromoCode: data['appliedPromoCode'],
      discountApplied: (data['discountApplied'] ?? 0).toDouble(),
      workPhotos: data['workPhotos'] != null
          ? List<String>.from(data['workPhotos'])
          : null,
      mechanicNotes: data['mechanicNotes'],
      customerNotes: data['customerNotes'],
      customerRating: data['customerRating']?.toDouble(),
      customerReview: data['customerReview'],
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellationReason'],
      rejectionReason: data['rejectionReason'],
      isEmergency: data['isEmergency'] ?? false,
    );
  }

  // Helper: Map Firestore doc to WithdrawalRequest
  WithdrawalRequest _mapDocToWithdrawal(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WithdrawalRequest(
      id: doc.id,
      mechanicId: data['mechanicId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      accountDetails: data['accountDetails'],
      requestDate: (data['requestDate'] as Timestamp).toDate(),
      status: _parseWithdrawalStatus(data['status']),
      processedDate: data['processedDate'] != null
          ? (data['processedDate'] as Timestamp).toDate()
          : null,
    );
  }

  // Helper: Parse status string to enum
  RequestStatus _parseRequestStatus(String? status) {
    switch (status) {
      case 'accepted':
        return RequestStatus.accepted;
      case 'inProgress':
        return RequestStatus.inProgress;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.pending;
    }
  }

  // Helper: Parse withdrawal status string to enum
  WithdrawalStatus _parseWithdrawalStatus(String? status) {
    switch (status) {
      case 'processing':
        return WithdrawalStatus.processing;
      case 'completed':
        return WithdrawalStatus.completed;
      case 'failed':
        return WithdrawalStatus.failed;
      case 'cancelled':
        return WithdrawalStatus.cancelled;
      default:
        return WithdrawalStatus.pending;
    }
  }
}
