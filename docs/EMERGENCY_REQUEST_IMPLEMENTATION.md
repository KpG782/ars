# Emergency Request Feature - Implementation Guide

## Overview

The Emergency Request feature allows customers to flag urgent service requests that require immediate mechanic attention. This document outlines how emergency requests are prioritized and displayed in the mechanic dashboard.

---

## 🔴 Emergency Request Flow

### Customer Side

1. **Triggering Emergency**

   - Customer taps "Emergency" or "Urgent" button during booking
   - Sets `isEmergency: true` in the ServiceRequest model
   - Visual indicator shows the request is flagged as urgent

2. **Backend Request Creation**
   ```dart
   ServiceRequest(
     id: generatedId,
     customerName: userData.name,
     location: customerLocation,
     serviceType: selectedService,
     description: description,
     estimatedPrice: price,
     requestTime: DateTime.now(),
     isEmergency: true,  // ← Emergency flag
     customerNotes: notes,
   )
   ```

---

## 🚨 Mechanic Dashboard Display

### Visual Indicators for Emergency Requests

#### 1. **Card Border & Background**

- **Red border** (2px width) instead of grey
- **Red-tinted background** (red with 2% opacity)
- **Enhanced shadow** with red tint for prominence

#### 2. **Emergency Banner**

- Appears at the top of the card
- Red background with white text
- Shows "EMERGENCY REQUEST" label
- "HIGH PRIORITY" badge on the right

```
┌─────────────────────────────────────────┐
│ 🚨 EMERGENCY REQUEST    [HIGH PRIORITY] │
├─────────────────────────────────────────┤
│ Customer Name          ₱300             │
│ Tire Problem           [URGENT]         │
│ Flat tire need immediate assistance     │
│                                         │
│ [Details]        [Accept Emergency]     │
└─────────────────────────────────────────┘
```

#### 3. **Color Coding**

- Avatar background: Red (instead of green)
- Service type icon: Red
- Price badge: Red background
- "URGENT" label next to service type
- Accept button: Red background with "Accept Emergency" text

---

## 📊 Priority Sorting Algorithm

Emergency requests are **always displayed first** in the mechanic's request list:

```dart
_nearbyRequests.sort((a, b) {
  // 1. Emergency requests always come first
  if (a.isEmergency && !b.isEmergency) return -1;
  if (!a.isEmergency && b.isEmergency) return 1;

  // 2. If both are emergency or both are regular,
  //    sort by request time (newer first)
  return b.requestTime.compareTo(a.requestTime);
});
```

### Sorting Priority:

1. **Emergency requests** (sorted by newest first)
2. **Regular requests** (sorted by newest first)

---

## 🔔 Notification Behavior

### For Emergency Requests:

- **Push notification** with high priority
- **Vibration pattern** (if enabled)
- **Custom notification sound** for emergencies
- **Badge counter** shows number of emergency requests

### Notification Content:

```
🚨 EMERGENCY SERVICE REQUEST
Tire Problem • ₱300
Juan Dela Cruz needs urgent help
[View] [Accept]
```

---

## 🗄️ Firebase Backend Integration

### Database Structure

#### Collection: `service_requests`

```json
{
  "id": "SR123456",
  "customerId": "C001",
  "customerName": "Juan Dela Cruz",
  "customerPhone": "+639171234567",
  "location": {
    "latitude": 14.5547,
    "longitude": 121.0244
  },
  "serviceType": "Tire Problem",
  "description": "Flat tire need immediate assistance",
  "estimatedPrice": 300.0,
  "requestTime": "2025-12-31T14:30:00Z",
  "status": "pending",
  "isEmergency": true, // ← Emergency flag
  "customerNotes": "Please hurry, I'm on the side of the highway",
  "createdAt": "2025-12-31T14:30:00Z",
  "updatedAt": "2025-12-31T14:30:00Z"
}
```

### Firestore Query for Mechanics

#### Get All Pending Requests (with Priority)

```dart
FirebaseFirestore.instance
  .collection('service_requests')
  .where('status', isEqualTo: 'pending')
  .where('location', isNearby: mechanicLocation, radius: 10km)
  .orderBy('isEmergency', descending: true)  // Emergency first
  .orderBy('requestTime', descending: true)  // Then by time
  .snapshots()
```

#### Filter Only Emergency Requests

```dart
FirebaseFirestore.instance
  .collection('service_requests')
  .where('status', isEqualTo: 'pending')
  .where('isEmergency', isEqualTo: true)
  .orderBy('requestTime', descending: true)
  .snapshots()
```

---

## 🎯 Business Rules

### Emergency Request Criteria:

1. ✅ Customer location is on highway/expressway
2. ✅ Customer explicitly marks as emergency
3. ✅ Service type is critical (e.g., "Dead Battery", "Tire Blowout")
4. ✅ Customer notes indicate urgency

### Mechanic Incentives:

- **Higher priority** in request feed
- **Emergency bonus** (e.g., +20% earnings)
- **Reputation boost** for accepting emergency requests
- **Penalty reduction** for quick emergency response

### SLA (Service Level Agreement):

- Emergency requests expire after **30 minutes** if not accepted
- Mechanic response time target: **Under 5 minutes**
- Arrival time target: **Under 20 minutes**

---

## 📱 Real-Time Updates

### Stream Subscription

```dart
StreamSubscription<QuerySnapshot>? _emergencyRequestsStream;

void _listenToEmergencyRequests() {
  _emergencyRequestsStream = FirebaseFirestore.instance
    .collection('service_requests')
    .where('status', isEqualTo: 'pending')
    .where('isEmergency', isEqualTo: true)
    .where('assignedMechanicId', isNull: true)
    .snapshots()
    .listen((snapshot) {
      if (snapshot.docChanges.any((change) =>
          change.type == DocumentChangeType.added)) {
        // New emergency request!
        _showEmergencyNotification();
        _playUrgentSound();
        _vibrate();
      }

      setState(() {
        _emergencyRequests = snapshot.docs
          .map((doc) => ServiceRequest.fromFirestore(doc))
          .toList();
      });
    });
}

@override
void dispose() {
  _emergencyRequestsStream?.cancel();
  super.dispose();
}
```

---

## 🎨 UI Components

### Emergency Badge Component

```dart
Widget _buildEmergencyBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.emergency, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        const Text(
          'EMERGENCY REQUEST',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'HIGH PRIORITY',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    ),
  );
}
```

---

## 📊 Analytics & Tracking

### Track Emergency Request Metrics:

1. **Response Time**: Time from request to mechanic acceptance
2. **Completion Time**: Time from acceptance to completion
3. **Success Rate**: % of emergency requests successfully completed
4. **Customer Satisfaction**: Rating for emergency services
5. **Mechanic Performance**: Average emergency response time per mechanic

### Firebase Analytics Events:

```dart
// When customer creates emergency request
FirebaseAnalytics.instance.logEvent(
  name: 'emergency_request_created',
  parameters: {
    'service_type': serviceType,
    'location': locationString,
    'estimated_price': price,
  },
);

// When mechanic accepts emergency request
FirebaseAnalytics.instance.logEvent(
  name: 'emergency_request_accepted',
  parameters: {
    'request_id': requestId,
    'mechanic_id': mechanicId,
    'response_time_seconds': responseTime,
  },
);

// When emergency service is completed
FirebaseAnalytics.instance.logEvent(
  name: 'emergency_service_completed',
  parameters: {
    'request_id': requestId,
    'total_duration_minutes': duration,
    'customer_rating': rating,
  },
);
```

---

## 🔐 Security Considerations

### Prevent Abuse:

1. **Rate Limiting**: Max 3 emergency requests per customer per day
2. **Verification**: Customer must provide reason for emergency
3. **Penalty System**: False emergencies result in warnings/suspension
4. **Review Process**: Flagged emergency requests reviewed by admin

### Backend Validation:

```dart
// Cloud Function to validate emergency request
exports.validateEmergencyRequest = functions.firestore
  .document('service_requests/{requestId}')
  .onCreate(async (snap, context) => {
    const request = snap.data();

    if (request.isEmergency) {
      // Check customer's recent emergency requests
      const recentEmergencies = await getRecentEmergencies(request.customerId);

      if (recentEmergencies.length >= 3) {
        // Too many emergency requests - flag for review
        await snap.ref.update({
          flagged: true,
          flagReason: 'Excessive emergency requests',
          requiresReview: true
        });

        // Notify admin
        await notifyAdmin(request);
      }

      // Send high-priority push notification to nearby mechanics
      await sendEmergencyNotification(request);
    }
  });
```

---

## ✅ Testing Checklist

### Visual Testing:

- [ ] Emergency requests show red border and background
- [ ] "EMERGENCY REQUEST" banner is visible
- [ ] "HIGH PRIORITY" badge displays correctly
- [ ] Avatar and icons are red-colored
- [ ] "URGENT" label appears next to service type
- [ ] Accept button shows "Accept Emergency" text

### Functional Testing:

- [ ] Emergency requests appear first in list
- [ ] Sorting maintains emergency priority
- [ ] Push notifications trigger for emergency requests
- [ ] Emergency sound plays on new request
- [ ] Real-time updates work correctly
- [ ] Backend query filters emergency requests

### Integration Testing:

- [ ] Customer can create emergency request
- [ ] Mechanic receives real-time notification
- [ ] Request appears in mechanic dashboard
- [ ] Acceptance flow works correctly
- [ ] Analytics events are logged
- [ ] Rate limiting prevents abuse

---

## 🚀 Deployment Steps

1. **Update ServiceRequest Model**: Ensure `isEmergency` field exists
2. **Deploy UI Changes**: Update service_request_card.dart
3. **Update Dashboard Logic**: Add priority sorting
4. **Configure Push Notifications**: Set up high-priority notifications
5. **Deploy Cloud Functions**: Validation and notification functions
6. **Update Firestore Rules**: Add security rules for emergency requests
7. **Test End-to-End**: Verify complete flow works
8. **Monitor Analytics**: Track emergency request metrics

---

## 📚 Related Files

### Core Files:

- `lib/features/mechanic/dashboard/data/models/service_request.dart`
- `lib/features/mechanic/dashboard/presentation/widgets/service_request_card.dart`
- `lib/features/mechanic/dashboard/presentation/screens/mechanic_dashboard.dart`

### Customer Files:

- `lib/features/customer/booking/presentation/screens/booking.dart`
- `lib/features/customer/booking/presentation/widgets/booking_bottom_panels.dart`

### Backend:

- `functions/src/validateEmergencyRequest.ts`
- `functions/src/sendEmergencyNotification.ts`

---

## 🎓 Best Practices

1. **Clear Visual Hierarchy**: Emergency requests MUST stand out
2. **Fast Response Time**: Optimize for quick mechanic acceptance
3. **Fair Distribution**: Don't overwhelm single mechanic with all emergencies
4. **Customer Communication**: Keep customer updated on mechanic ETA
5. **Feedback Loop**: Track and improve emergency response metrics

---

## 📝 Future Enhancements

### Phase 2:

- [ ] Auto-assign emergency to nearest available mechanic after 2 minutes
- [ ] Emergency request escalation (increase visibility over time)
- [ ] Premium emergency service tier with guaranteed response
- [ ] Emergency request heatmap for analytics

### Phase 3:

- [ ] AI-based emergency detection from customer description
- [ ] Voice call integration for emergency verification
- [ ] Live location sharing during emergency service
- [ ] Emergency contact auto-notification (customer's emergency contact)

---

**Last Updated**: December 31, 2025
**Version**: 1.0.0
**Status**: ✅ Ready for Backend Integration
