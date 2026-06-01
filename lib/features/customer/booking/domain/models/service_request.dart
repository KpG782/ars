import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

enum ServiceRequestStatus {
  pending,
  accepted,
  enRoute,
  inProgress,
  completed,
  cancelled,
  expired;

  String get value => name;

  static ServiceRequestStatus fromString(String value) {
    return ServiceRequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ServiceRequestStatus.pending,
    );
  }

  bool get isActive =>
      this == accepted || this == enRoute || this == inProgress;
  bool get isTerminal =>
      this == completed || this == cancelled || this == expired;
}

class ServiceRequest {
  final String id;
  final String customerId;
  final String? mechanicId;
  final ServiceRequestStatus status;
  final String serviceType;
  final String? subServiceType;
  final bool isEmergency;
  final LatLng customerLocation;
  final String? customerAddress;
  final String? description;
  final double? estimatedPrice;
  final double? finalPrice;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.mechanicId,
    required this.status,
    required this.serviceType,
    this.subServiceType,
    this.isEmergency = false,
    required this.customerLocation,
    this.customerAddress,
    this.description,
    this.estimatedPrice,
    this.finalPrice,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory ServiceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locMap = data['customerLocation'] as Map<String, dynamic>;
    return ServiceRequest(
      id: doc.id,
      customerId: data['customerId'] as String,
      mechanicId: data['mechanicId'] as String?,
      status: ServiceRequestStatus.fromString(data['status'] as String),
      serviceType: data['serviceType'] as String,
      subServiceType: data['subServiceType'] as String?,
      isEmergency: data['isEmergency'] as bool? ?? false,
      customerLocation: LatLng(
        (locMap['lat'] as num).toDouble(),
        (locMap['lng'] as num).toDouble(),
      ),
      customerAddress: data['customerAddress'] as String?,
      description: data['description'] as String?,
      estimatedPrice: (data['estimatedPrice'] as num?)?.toDouble(),
      finalPrice: (data['finalPrice'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'mechanicId': mechanicId,
      'status': status.value,
      'serviceType': serviceType,
      'subServiceType': subServiceType,
      'isEmergency': isEmergency,
      'customerLocation': {
        'lat': customerLocation.latitude,
        'lng': customerLocation.longitude,
      },
      'customerAddress': customerAddress,
      'description': description,
      'estimatedPrice': estimatedPrice,
      'finalPrice': finalPrice,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }

  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? mechanicId,
    ServiceRequestStatus? status,
    String? serviceType,
    String? subServiceType,
    bool? isEmergency,
    LatLng? customerLocation,
    String? customerAddress,
    String? description,
    double? estimatedPrice,
    double? finalPrice,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      mechanicId: mechanicId ?? this.mechanicId,
      status: status ?? this.status,
      serviceType: serviceType ?? this.serviceType,
      subServiceType: subServiceType ?? this.subServiceType,
      isEmergency: isEmergency ?? this.isEmergency,
      customerLocation: customerLocation ?? this.customerLocation,
      customerAddress: customerAddress ?? this.customerAddress,
      description: description ?? this.description,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
