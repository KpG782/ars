// One-time dev script — approve all mechanics in Firestore.
//
// The booking controller queries `verification.status == 'approved'` but
// mechanics who sign up via the app only get `verificationStatus.state = 'pending'`.
// This script patches every mechanic doc to add the correct `verification` map.
//
// HOW TO RUN:
//   1. Add `await approveAllMechanics();` in main.dart BEFORE runApp()
//   2. Hot-restart once
//   3. Check console logs — "Approved X mechanics"
//   4. Remove the call and delete this file

import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';

Future<void> approveAllMechanics() async {
  final firestore = FirebaseFirestore.instance;

  try {
    final snapshot = await firestore.collection('mechanics').get();
    int updated = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Check if already approved via the booking query path
      final verificationMap = data['verification'] as Map<String, dynamic>?;
      if (verificationMap?['status'] == 'approved') {
        appLogger.i('  ✓ ${doc.id} already approved — skipping');
        continue;
      }

      // Patch with the fields the booking controller expects
      await firestore.collection('mechanics').doc(doc.id).set({
        'verification': {'status': 'approved', 'isVerified': true},
        // Also update the auth model's verificationStatus so the mechanic
        // app shows "Verified" on the splash screen
        'verificationStatus': {
          'state': 'verified',
          'rejectionReason': null,
          'verifiedAt': FieldValue.serverTimestamp(),
        },
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final name =
          (data['basicInfo'] as Map<String, dynamic>?)?['fullName'] ?? doc.id;
      appLogger.i('  ✅ Approved: $name');
      updated++;
    }

    appLogger.i(
      'approve_all_mechanics: patched $updated of ${snapshot.docs.length} mechanics',
    );
  } catch (e, st) {
    appLogger.e('approve_all_mechanics failed', error: e, stackTrace: st);
  }
}
