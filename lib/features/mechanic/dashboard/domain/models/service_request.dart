/// Domain Model: ServiceRequest
///
/// Represents a service request from a customer in the business domain.
/// This model is independent of any data source (Firebase, REST API, etc.)
library;

import 'package:latlong2/latlong.dart';

/// Status of a service request
enum RequestStatus { pending, accepted, inProgress, completed, cancelled }

/// Main service request entity
class ServiceRequest {
  final String id;
  final String customerId; // Firebase Auth UID of the customer
  final String customerName;
  final LatLng location;
  final String serviceType;
  final String description;
  final double estimatedPrice;
  final double? actualPrice; // Updated after service
  final DateTime requestTime;
  final DateTime? completionTime; // When service was completed
  final RequestStatus status;
  final String? customerPhone;
  final String? customerPhoto;
  final double tipAmount; // Tip from customer
  final String? appliedPromoCode; // If customer used promo code
  final double discountApplied; // Amount discounted
  final List<String>? workPhotos; // Photos of completed work
  final String? mechanicNotes; // What mechanic did
  final String? customerNotes; // Special instructions from customer
  final double? customerRating; // 5-star rating
  final String? customerReview; // Review text
  final DateTime? startTime; // When mechanic started working
  final String? cancellationReason; // If service was cancelled
  final String? rejectionReason; // If mechanic rejected request
  final bool isEmergency; // Priority service

  ServiceRequest({
    required this.id,
    this.customerId = '',
    required this.customerName,
    required this.location,
    required this.serviceType,
    required this.description,
    required this.estimatedPrice,
    this.actualPrice,
    required this.requestTime,
    this.completionTime,
    this.status = RequestStatus.pending,
    this.customerPhone,
    this.customerPhoto,
    this.tipAmount = 0.0,
    this.appliedPromoCode,
    this.discountApplied = 0.0,
    this.workPhotos,
    this.mechanicNotes,
    this.customerNotes,
    this.customerRating,
    this.customerReview,
    this.startTime,
    this.cancellationReason,
    this.rejectionReason,
    this.isEmergency = false,
  });

  // Business logic: Calculate mechanic earnings
  double get mechanicEarnings {
    final basePrice = actualPrice ?? estimatedPrice;
    final platformFee = basePrice * 0.15; // 15% platform fee
    final earnings = basePrice - platformFee + tipAmount;
    return earnings;
  }

  // Business logic: Get platform fee
  double get platformFee {
    final basePrice = actualPrice ?? estimatedPrice;
    return basePrice * 0.15;
  }

  // Business logic: Calculate service duration
  Duration? get serviceDuration {
    if (startTime != null && completionTime != null) {
      return completionTime!.difference(startTime!);
    }
    return null;
  }

  // Business logic: Get formatted service duration
  String get formattedDuration {
    final duration = serviceDuration;
    if (duration == null) return 'N/A';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours hr $minutes min';
    }
    return '$minutes min';
  }

  // Business logic: Check if service is completed
  bool get isCompleted => status == RequestStatus.completed;

  // Business logic: Check if service is in progress
  bool get isInProgress =>
      status == RequestStatus.accepted || status == RequestStatus.inProgress;

  // Business logic: Check if service can be cancelled
  bool get canBeCancelled =>
      status == RequestStatus.pending || status == RequestStatus.accepted;

  // Business logic: Get total customer payment
  double get totalCustomerPayment {
    final basePrice = actualPrice ?? estimatedPrice;
    return basePrice - discountApplied + tipAmount;
  }

  // Business logic: Get net earnings after all deductions
  double get netEarnings => mechanicEarnings;

  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? customerName,
    LatLng? location,
    String? serviceType,
    String? description,
    double? estimatedPrice,
    double? actualPrice,
    DateTime? requestTime,
    DateTime? completionTime,
    RequestStatus? status,
    String? customerPhone,
    String? customerPhoto,
    double? tipAmount,
    String? appliedPromoCode,
    double? discountApplied,
    List<String>? workPhotos,
    String? mechanicNotes,
    String? customerNotes,
    double? customerRating,
    String? customerReview,
    DateTime? startTime,
    String? cancellationReason,
    String? rejectionReason,
    bool? isEmergency,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      location: location ?? this.location,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      actualPrice: actualPrice ?? this.actualPrice,
      requestTime: requestTime ?? this.requestTime,
      completionTime: completionTime ?? this.completionTime,
      status: status ?? this.status,
      customerPhone: customerPhone ?? this.customerPhone,
      customerPhoto: customerPhoto ?? this.customerPhoto,
      tipAmount: tipAmount ?? this.tipAmount,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      discountApplied: discountApplied ?? this.discountApplied,
      workPhotos: workPhotos ?? this.workPhotos,
      mechanicNotes: mechanicNotes ?? this.mechanicNotes,
      customerNotes: customerNotes ?? this.customerNotes,
      customerRating: customerRating ?? this.customerRating,
      customerReview: customerReview ?? this.customerReview,
      startTime: startTime ?? this.startTime,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }
}
