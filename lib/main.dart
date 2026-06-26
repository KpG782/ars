import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  // ProviderScope is the Riverpod root. Phase 1 adds a guarded
  // Firebase.initializeApp() here (try/catch so the app still boots without
  // real config), then overrides the Fake repositories with Firestore ones.
  runApp(const ProviderScope(child: TalyerApp()));
}
