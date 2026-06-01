# 🚗 ARS Application - Auto Repair Service

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/OSRM-Self--Hosted-00BFA5?style=for-the-badge&logo=openstreetmap&logoColor=white" alt="OSRM">
  <img src="https://img.shields.io/badge/AI-Gemini%202.0-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI">
</div>

## 📱 About

**ARS (Auto Repair Service)** is a comprehensive mobile application that connects vehicle owners with professional mechanics for on-demand automotive repair services. Built with Flutter and powered by Firebase, this app provides a seamless experience for booking, tracking, and managing vehicle repair services.

### ✨ Key Features

- 🤖 **AI Diagnostic Chatbot** - 87.4% accurate automotive diagnosis with Taglish support (201 terms, 97.5% accuracy)
- 💰 **Smart Cost Estimation** - Metro Manila pricing with urgency classification
- 🗺️ **Real-time Location Services** - Find nearby mechanics and track service requests
- 👤 **User Authentication** - Secure login/registration with Firebase Auth
- 🚙 **Vehicle Management** - Add and manage multiple vehicles
- 🔧 **Service Booking** - Book various automotive services (Engine, Brake, Tire, etc.)
- 💬 **Real-time Communication** - Chat with mechanics during service
- 📊 **Service Tracking** - Monitor repair progress in real-time
- 🏪 **Mechanic Dashboard** - Dedicated interface for service providers
- 📱 **Cross-platform** - Available on Android and iOS

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**

   ```bash
   git clone <your-repository-url>
   cd ARSAPPLICATION
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Ask to be invited to Firebase project `ars-application-be8f1` in Firebase Console
     (Project Settings -> Users and permissions).
   - Install FlutterFire CLI (one-time):
     ```bash
     dart pub global activate flutterfire_cli
     ```
   - Generate Firebase files locally (official workflow):
     ```bash
     flutterfire configure --project=ars-application-be8f1
     ```
     If `flutterfire` is not recognized in PATH, use:
     ```bash
     dart pub global run flutterfire_cli:flutterfire configure --project=ars-application-be8f1
     ```
   - This command auto-generates:
     - `lib/firebase_options.dart`
     - `android/app/google-services.json`
     - Apple Firebase config files when applicable
   - Do not manually copy Firebase files between teammates.

4. **Chatbot API Key Setup (.env)**

   - Copy the template file:
     ```bash
     cp .env.example .env
     ```
     On Windows PowerShell:
     ```powershell
     Copy-Item .env.example .env
     ```
   - Set your chatbot API key in `.env`:
     ```env
     ARS_CHATBOT_API_KEY=YOUR_KEY_HERE
     ```

5. **Configure Android Permissions**

   Ensure these permissions are in `android/app/src/main/AndroidManifest.xml`:

   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   ```

6. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

ARS follows a **Feature-First Clean Architecture** approach, organizing code by features with clear separation of concerns:

```
lib/
├── core/                          # Shared core functionality
│   ├── auth/                      # Authentication services
│   │   └── auth_service.dart      # Firebase Auth wrapper
│   ├── constants/                 # App-wide constants
│   │   ├── app_strings.dart       # String constants
│   │   └── app_constants.dart     # General constants
│   ├── models/                    # Shared models
│   │   └── notification_model.dart
│   ├── theme/                     # App theming
│   │   └── app_theme.dart
│   ├── utils/                     # Utility functions
│   │   └── toast_helper.dart      # Toast notifications
│   └── widgets/                   # Reusable widgets
│       ├── custom_button.dart
│       └── custom_text_field.dart
├── features/                      # Feature modules
│   ├── onboarding/                # App onboarding
│   │   └── presentation/
│   │       └── screens/           # Splash, loading, onboarding
│   ├── customer/                  # Customer-facing features
│   │   ├── auth/                  # Customer authentication
│   │   ├── booking/               # Service booking
│   │   ├── vehicles/              # Vehicle management
│   │   ├── dashboard/             # Customer dashboard
│   │   └── support/               # Customer support
│   └── mechanic/                  # Mechanic-facing features
│       ├── auth/                  # Mechanic authentication
│       ├── dashboard/             # Mechanic dashboard
│       ├── services/              # Service management
│       └── earnings/              # Earnings tracking
├── examples/                      # Integration examples
│   ├── customer_notification_integration.dart
│   └── mechanic_notification_integration.dart
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # Application entry point
```

### Architecture Principles

- **Feature-First:** Code organized by business features (customer/mechanic)
- **Clean Architecture:** Separation into data, domain, and presentation layers
- **Shared Core:** Common services accessible across features
- **Single Responsibility:** Each module handles one specific concern

## 🛠️ Technology Stack

- **Framework:** Flutter 3.9+
- **Language:** Dart 3.9+
- **Architecture:** Feature-First Clean Architecture
- **AI/ML Integration:**
  - **ARS Rapide API** - Custom FastAPI diagnostic chatbot
  - Google Gemini 2.0 Flash (LLM inference)
  - LangGraph (Agentic state machine)
  - ChromaDB (Vector database for semantic search)
  - RAG (Retrieval-Augmented Generation)
  - Redis caching (50%+ faster responses)
- **Backend Services:** Firebase
  - Firebase Authentication (Email/Password)
  - Cloud Firestore (NoSQL Database)
  - Cloud Storage (File uploads)
  - Firebase Messaging (Push notifications)
- **Maps & Location:**
  - Flutter Map with OpenStreetMap tiles
  - Google Maps Flutter
  - Geolocator for GPS positioning
  - **OSRM (Self-Hosted)** - Custom routing engine for ETA calculations
- **Notifications:**
  - Firebase Cloud Messaging
  - Flutter Local Notifications
- **UI Components:**
  - Material Design 3
  - Flutter Lucide Icons
  - Flutter SVG
  - Custom Toast Helper
- **Media & Files:**
  - Image Picker
  - File Picker
- **State Management:** StatefulWidget with setState()
- **Networking:** HTTP package
- **Persistence:** SharedPreferences
- **Build Tools:** Gradle (Android)

## 🔌 API Integrations

ARS Application integrates with multiple external APIs and services to provide comprehensive functionality:

### 🤖 AI & Machine Learning
- **ARS Rapide Diagnostic API** (Custom FastAPI)
  - Endpoint: `/chat` - AI-powered automotive diagnosis
  - Features: RAG-based diagnosis, Taglish support, cost estimation
  - Authentication: X-API-Key header
  - Response Time: 3.7s (cache miss) / <1s (cache hit)
  - Accuracy: 87.4% diagnostic accuracy

### 🔥 Firebase Services
- **Firebase Authentication API**
  - Email/password authentication
  - User session management
  - Token refresh handling
  
- **Cloud Firestore API**
  - Real-time database operations
  - Collections: users, mechanics, service_requests, bookings, vehicles, chats
  - Real-time listeners for live updates
  
- **Firebase Cloud Storage API**
  - Document uploads (NBI, licenses, certificates)
  - Vehicle photos
  - Profile images
  
- **Firebase Cloud Messaging (FCM) API**
  - Push notifications for booking updates
  - Real-time alerts for mechanics
  - Chat message notifications

### 🗺️ Location & Mapping Services
- **Google Maps API**
  - Map visualization
  - Location services
  - Geocoding and reverse geocoding
  
- **OpenStreetMap Tiles API**
  - Alternative map tiles provider
  - Offline-capable mapping
  
- **OSRM (Open Source Routing Machine) API** ⭐ Self-Hosted
  - Custom self-hosted OSRM server built from scratch
  - Real-time route calculation between customer and mechanic
  - ETA (Estimated Time of Arrival) calculations with auto-refresh (every 30s)
  - Distance optimization using road network data
  - Turn-by-turn navigation support
  - Fallback calculation when routing unavailable
  - No external API costs - fully owned infrastructure
  - Manila/Philippines road network optimized
  
- **Geolocator API**
  - Real-time GPS tracking
  - Location permissions handling
  - Background location updates

### 🧠 Google AI Services
- **Google Gemini 2.0 Flash API**
  - Natural language processing
  - Automotive problem analysis
  - Conversational AI responses
  - Cost: $0.07 per 1M tokens

### ⚡ Performance & Caching
- **Redis Cache API**
  - Response caching for diagnostic queries
  - 50%+ performance improvement on repeated queries
  - Session management

### 📊 Monitoring & Analytics
- **Prometheus Metrics API**
  - Request tracking
  - Performance monitoring
  - Confidence score analytics
  - Custom business metrics

### API Rate Limits & Costs
| Service | Rate Limit | Monthly Cost (Est.) |
|---------|-----------|---------------------|
| ARS Rapide API | 10 req/min per IP | Included |
| Firebase (Spark Plan) | 50K reads/day | Free |
| Google Maps API | Pay-as-you-go | $5-20 |
| Gemini 2.0 Flash | No hard limit | $0.35 (10K users) |
| OSRM (Self-hosted) | Unlimited | Free (Own Server) |
| FCM | Unlimited | Free |

**Total Monthly Infrastructure Cost:** ~$20-25 for 10,000 active users

## 🎯 Features in Detail

### For Vehicle Owners (Customers)

- **AI-Powered Diagnostics:** Chat with an intelligent assistant that analyzes car problems with 87.4% accuracy
  - Supports Taglish (Filipino + English) with 201 automotive terms
  - Multi-symptom analysis for complex issues
  - Cost estimates based on Metro Manila pricing (₱800-₱15,000 range)
  - Urgency classification (Immediate / High / Medium / Low)
- **Quick Service Booking:** Select from various automotive services (Engine, Brake, Tire, Battery, Oil Change, AC)
- **Real-time Map View:** See available mechanics and your current location on an interactive map
- **Live ETA Tracking:** Self-hosted OSRM routing engine calculates accurate mechanic arrival times
  - Auto-refreshes every 30 seconds
  - Displays distance and estimated time
  - Accuracy indicators for route confidence
  - Optimized for Metro Manila road networks
- **Vehicle Management:** Add and manage multiple vehicles with details (brand, model, year, plate)
- **Service Tracking:** Monitor booking status from request to completion
- **In-App Chat:** Communicate directly with assigned mechanic during service
- **Emergency Requests:** Quick access to urgent repair services

### For Mechanics (Service Providers)

- **Professional Onboarding:** Register with required documentation (NBI, Driver's License, Certificate)
- **Live Dashboard:** View nearby service requests on an interactive map
- **Real-time ETA Display:** Self-hosted routing shows accurate travel time to customer locations
- **Online/Offline Toggle:** Control availability status
- **Service Request Management:** Accept requests and update job status (Idle, En Route, On Service, Completed)
- **Customer Communication:** Chat with customers about service details
- **Earnings Dashboard:** Track completed services and income
- **Service History:** View all past and current jobs

## 🚧 Roadmap

### ✅ Completed Features
- [x] **Feature-First Architecture** - Clean architecture implementation
- [x] **Customer Authentication** - Email/password login and registration
- [x] **Mechanic Onboarding** - Professional registration with documentation
- [x] **Service Booking** - Complete booking flow with map integration
- [x] **Real-time Location** - GPS tracking and map visualization
- [x] **Self-Hosted OSRM Integration** - Custom routing engine for accurate ETAs
  - ✅ Real-time ETA calculations with 30-second auto-refresh
  - ✅ Distance and duration tracking
  - ✅ Metro Manila road network optimized
  - ✅ Fallback calculation for reliability
- [x] **Vehicle Management** - Add/edit multiple vehicles
- [x] **Live Dashboards** - Separate interfaces for customers and mechanics
- [x] **In-App Chat** - Communication between customer and mechanic
- [x] **Push Notifications** - Firebase Cloud Messaging integration
- [x] **Emergency Requests** - Quick access to emergency repair services
- [x] **Loading States** - Comprehensive loading state management
- [x] **Toast Notifications** - User-friendly toast messaging system
- [x] **Branding Update** - Updated UI/UX with new branding
- [x] **Onboarding Flow** - Splash screen and app introduction
- [x] **AI Diagnostic Chatbot** - Production-ready chatbot with 87.4% accuracy
  - ✅ Taglish support (201 terms, 97.5% accuracy)
  - ✅ Cost estimation (Metro Manila pricing)
  - ✅ Urgency classification
  - ✅ Multi-symptom analysis
  - ✅ Redis caching for faster responses

### 🚧 In Progress / Planned
- [ ] **Payment Integration** - Stripe/PayPal/GCash integration
- [ ] **Review System** - Rate and review mechanics after service
- [ ] **Service History** - Enhanced history for customers and mechanics
- [ ] **Advanced Filters** - Filter by service type, price, rating
- [ ] **Multi-language Support** - Full Tagalog and English localization
- [ ] **Dark Mode** - Enhanced UI themes
- [ ] **Offline Mode** - Cache data for offline access
- [ ] **AI Chat History** - Save and review past diagnostic conversations

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow [Flutter style guide](https://docs.flutter.dev/development/tools/formatting)
- Adhere to feature-first clean architecture principles
- Keep features isolated and independent
- Place shared code in `core/` directory
- Write meaningful commit messages
- Test your changes thoroughly before submitting PR
- Update documentation when adding new features
- Run `flutter analyze` before committing

### Code Organization Rules

- **Customer features** → `lib/features/customer/`
- **Mechanic features** → `lib/features/mechanic/`
- **Shared services** → `lib/core/`
- Each feature should have: `data/`, `domain/`, `presentation/` layers
- Models go in `data/models/`
- Screens go in `presentation/screens/`
- Widgets go in `presentation/widgets/`

## 🔧 Configuration

### Firebase Configuration

The app uses `firebase_options.dart` for Firebase initialization. Update the following:

```dart
// lib/firebase_options.dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-api-key',
  appId: 'your-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'your-project-id',
  storageBucket: 'your-storage-bucket',
);
```

### Firestore Security Rules

Configure your Firestore database with proper security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Service requests
    match /service_requests/{requestId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Mechanics collection
    match /mechanics/{mechanicId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == mechanicId;
    }
  }
}
```

### Android Configuration

Key configuration files:

- `android/app/build.gradle.kts` - Dependencies and SDK versions
- `android/app/google-services.json` - Firebase configuration
- `android/app/src/main/AndroidManifest.xml` - Permissions and metadata

## Documentation

Detailed documentation is available in the [docs index](docs/README.md).

Start with:

- [Architecture](docs/ARCHITECTURE.md) - project structure, layers, and naming conventions.
- [Setup and Health Audit](docs/AUDIT.md) - current build, Firebase, analyzer, test, and cleanup status.
- [Authoring Guide](docs/AUTHOR_GUIDE.md) - rules for keeping Markdown organized.
- [OSRM Quick Start](docs/QUICK_START_OSRM.md) - routing and ETA setup.
- [Mechanic Flow Update Plan](docs/mechanics_update.md) - mechanic-side product gaps and priorities.
- [Emergency Request Implementation](docs/EMERGENCY_REQUEST_IMPLEMENTATION.md) - emergency request system.
- [Notification Implementation](docs/NOTIFICATION_IMPLEMENTATION.md) - push notification setup.
- [Chat Feature](docs/chat-feature.md) - real-time chat implementation.
- [Loading States Implementation](docs/LOADING_STATES_IMPLEMENTATION.md) - loading-state patterns.

## Support

For questions, issues, or contributions:

- 🐛 **Report Issues:** Create an issue in your repository
- 📖 **Documentation:** See the Documentation section above for all available guides
- 💬 **Contact:** Reach out through your preferred communication channel

## 📊 Project Status

- ✅ **Architecture:** Feature-first clean architecture implemented
- ✅ **Authentication:** Customer and mechanic auth flows complete
- ✅ **Core Features:** Booking, dashboard, vehicle management functional
- ✅ **AI Integration:** Production-ready diagnostic chatbot (95% ready for deployment)
  - 87.4% diagnostic accuracy with RAG + confidence boosting
  - 97.5% Taglish accuracy (201 Filipino automotive terms)
  - Metro Manila cost estimation (₱800-₱15,000 range)
  - Redis caching (50%+ faster responses)
- ✅ **Location Services:** GPS tracking, self-hosted OSRM routing engine, and maps integrated
  - Custom-built routing API for Metro Manila
  - Real-time ETA with 30-second refresh intervals
  - Zero external routing API costs
- ✅ **Notifications:** Push notifications and local notifications implemented
- ✅ **UI/UX:** Loading states, toasts, and branding updates complete
- 🚧 **In Progress:** Payment integration
- 📅 **Next:** Review system, service history enhancements, advanced filters

## 📄 License

License information is not included yet. Add a `LICENSE` file before publishing or distributing the project.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- OpenStreetMap for mapping services
- All contributors and testers

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p>
    <a href="#top">⬆️ Back to Top</a>
  </p>
</div>
