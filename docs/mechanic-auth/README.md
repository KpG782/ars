# Mechanic Auth Module - Clean Architecture

## 📚 Overview

This module implements the mechanic authentication flow using **Clean Architecture** principles and **SOLID** design patterns. The architecture is modular, scalable, testable, and maintainable.

## 🏗️ Architecture Layers

```
lib/features/mechanic/auth/
├── domain/                    # Business Logic Layer (Pure Dart)
│   ├── models/               # Domain Entities & Value Objects
│   │   └── mechanic_user.dart
│   └── repositories/         # Repository Interfaces (Contracts)
│       └── auth_repository.dart
├── data/                     # Data Layer (Infrastructure)
│   └── repositories/        # Repository Implementations
│       ├── firebase_auth_repository.dart
│       ├── firebase_mechanic_data_repository.dart
│       └── firebase_storage_repository.dart
└── presentation/            # Presentation Layer (UI)
    ├── screens/            # Screen Widgets
    ├── widgets/            # Reusable Widgets
    │   └── auth_widgets.dart
    └── utils/              # UI Utilities
        └── form_validators.dart
```

## 🎯 SOLID Principles Applied

### 1. **Single Responsibility Principle (SRP)**
Each class has one reason to change:
- `MechanicUser` - Handles mechanic user data only
- `BasicInfo` - Handles basic personal info only
- `ProfessionalInfo` - Handles professional credentials only
- `AuthRepository` - Handles authentication operations only
- `MechanicDataRepository` - Handles data operations only
- `FileStorageRepository` - Handles file operations only

### 2. **Open/Closed Principle (OCP)**
- Classes are open for extension but closed for modification
- `FormValidators` can be extended with new validators without modifying existing code
- Repository interfaces allow new implementations without changing domain logic

### 3. **Liskov Substitution Principle (LSP)**
- Repository implementations can be swapped without breaking functionality
- `FirebaseAuthRepository` can be replaced with `RestApiAuthRepository` seamlessly

### 4. **Interface Segregation Principle (ISP)**
- Repositories are split into focused interfaces:
  - `AuthRepository` - Auth operations
  - `MechanicDataRepository` - Data operations
  - `FileStorageRepository` - File operations
- Clients only depend on methods they use

### 5. **Dependency Inversion Principle (DIP)**
- High-level modules (domain) don't depend on low-level modules (data)
- Both depend on abstractions (repository interfaces)
- Easy to mock for testing

## 🔄 DRY Principle (Don't Repeat Yourself)

### Reusable Components Created:

1. **Form Validators** (`form_validators.dart`)
   - Single source of truth for validation logic
   - Reusable across all forms
   - Easy to maintain and test

2. **Auth Widgets** (`auth_widgets.dart`)
   - `CustomTextField` - Consistent input fields
   - `PrimaryButton` - Branded buttons
   - `SecondaryButton` - Outlined buttons
   - `FileUploadCard` - Document upload UI
   - `LoadingOverlay` - Loading states
   - `ErrorMessage` - Error display
   - `InfoCard` - Information display

3. **Domain Models** (`mechanic_user.dart`)
   - Reusable value objects
   - Consistent data transformation (toMap/fromMap)
   - Immutable by design

## 📦 Domain Models

### Core Entities

#### `MechanicUser`
Main aggregate root representing a mechanic user:
```dart
MechanicUser(
  uid: String,
  basicInfo: BasicInfo,
  professionalInfo: ProfessionalInfo,
  verificationStatus: VerificationStatus,
  createdAt: DateTime,
  updatedAt: DateTime?,
)
```

#### `BasicInfo` (Value Object)
Personal information:
```dart
BasicInfo(
  firstName: String,
  lastName: String,
  username: String,
  email: String,
  phoneNumber: String,
)
```

#### `ProfessionalInfo` (Value Object)
Professional credentials:
```dart
ProfessionalInfo(
  specialization: String,
  yearsOfExperience: int,
  businessName: String?,
  licenseNumber: String?,
  address: String?,
  documentUrls: DocumentUrls,
)
```

#### `VerificationStatus` (Value Object)
Verification state:
```dart
VerificationStatus(
  state: VerificationState,  // pending, verified, rejected, underReview
  adminComments: String?,
  verifiedAt: DateTime?,
)
```

## 🔌 Repository Pattern

### Why Repository Pattern?

1. **Abstraction**: Hides data source implementation details
2. **Testability**: Easy to mock for unit tests
3. **Flexibility**: Swap implementations without affecting business logic
4. **Centralized Data Access**: Single source of truth for data operations

### Repository Interfaces

#### `AuthRepository`
```dart
Future<MechanicUser> signUp(...)
Future<MechanicUser> signIn(...)
Future<void> signOut()
Future<MechanicUser?> getCurrentUser()
Future<void> sendPasswordResetEmail(String email)
// ... more methods
```

#### `MechanicDataRepository`
```dart
Future<void> saveProfessionalDetails(...)
Future<MechanicUser?> getMechanicByUid(String uid)
Future<void> updateVerificationStatus(...)
Future<bool> isUsernameAvailable(String username)
// ... more methods
```

#### `FileStorageRepository`
```dart
Future<String> uploadFile(...)
Future<String> downloadFile(...)
Future<void> deleteFile(String storagePath)
Future<String> getDownloadUrl(String storagePath)
```

## 🛠️ Form Validators

Comprehensive validation functions:

```dart
// Email validation
FormValidators.email(value)

// Password validation (8+ chars, uppercase, lowercase, number, special char)
FormValidators.password(value)

// Password confirmation
FormValidators.confirmPassword(originalPassword)

// Phone number (10 digits)
FormValidators.phoneNumber(value)

// Name validation
FormValidators.name(value, fieldName: 'First name')

// Combine validators
FormValidators.combine([
  FormValidators.required,
  FormValidators.email,
])
```

## 🎨 Reusable Widgets

### CustomTextField
```dart
CustomTextField(
  controller: _emailController,
  label: 'Email Address',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: FormValidators.email,
)
```

### PrimaryButton
```dart
PrimaryButton(
  label: 'Sign In',
  onPressed: _handleSignIn,
  isLoading: _isLoading,
  icon: Icons.login,
)
```

### FileUploadCard
```dart
FileUploadCard(
  title: 'Professional License',
  fileName: _licenseFileName,
  isRequired: true,
  onTap: () => _pickFile('license'),
  icon: Icons.badge,
)
```

## ⚠️ Error Handling

### Custom Exceptions

1. **AuthException**
   - Email already in use
   - Weak password
   - Invalid email
   - User not found
   - Wrong password
   - Network errors

2. **DataException**
   - Not found
   - Permission denied
   - Already exists
   - Invalid data

3. **StorageException**
   - Upload failed
   - File not found
   - Quota exceeded
   - Unauthorized

### Error Codes
All exceptions include error codes for precise error handling:
```dart
try {
  await authRepository.signIn(email: email, password: password);
} on AuthException catch (e) {
  if (e.code == AuthErrorCode.wrongPassword) {
    // Handle wrong password
  }
}
```

## 🧪 Testing Strategy

### Unit Tests
```dart
// Mock repositories
class MockAuthRepository extends Mock implements AuthRepository {}

// Test domain logic
test('should create valid mechanic user', () {
  final user = MechanicUser(...);
  expect(user.uid, isNotEmpty);
  expect(user.basicInfo.fullName, 'John Doe');
});

// Test validators
test('should validate email correctly', () {
  expect(FormValidators.email('invalid'), isNotNull);
  expect(FormValidators.email('valid@email.com'), isNull);
});
```

### Integration Tests
```dart
// Test with real Firebase (emulator)
testWidgets('should sign in successfully', (tester) async {
  // Test full auth flow
});
```

## 📖 Usage Examples

### Sign Up Flow

```dart
// 1. Create repository instances
final authRepo = FirebaseAuthRepository();
final dataRepo = FirebaseMechanicDataRepository();

// 2. Sign up
final basicInfo = BasicInfo(
  firstName: 'John',
  lastName: 'Doe',
  username: 'johndoe',
  email: 'john@example.com',
  phoneNumber: '+639123456789',
);

final user = await authRepo.signUp(
  basicInfo: basicInfo,
  password: 'SecurePass123!',
);

// 3. Save professional details
await dataRepo.saveProfessionalDetails(
  uid: user.uid,
  professionalInfo: professionalInfo,
);
```

### Sign In Flow

```dart
try {
  final user = await authRepo.signIn(
    email: 'john@example.com',
    password: 'SecurePass123!',
  );
  
  // Navigate based on verification status
  if (user.verificationStatus.isVerified) {
    // Go to dashboard
  } else {
    // Go to verification status screen
  }
} on AuthException catch (e) {
  // Show error message
  showError(e.message);
}
```

## 🔐 Security Best Practices

1. **Password Requirements**
   - Minimum 8 characters
   - At least one uppercase letter
   - At least one lowercase letter
   - At least one number
   - At least one special character

2. **Email Verification**
   - Sent automatically on signup
   - Required before full access

3. **Data Validation**
   - Client-side validation (immediate feedback)
   - Server-side validation (security)

4. **Secure Storage**
   - Sensitive documents stored in Firebase Storage
   - Access controlled via Firestore Security Rules

## 🚀 Migration Guide

### From Old Code to New Architecture

1. **Replace direct Firebase calls**:
   ```dart
   // Old
   await FirebaseAuth.instance.signInWithEmailAndPassword(...)
   
   // New
   await authRepository.signIn(email: email, password: password)
   ```

2. **Use domain models**:
   ```dart
   // Old
   Map<String, dynamic> userData = {...}
   
   // New
   MechanicUser user = MechanicUser(...)
   ```

3. **Use reusable widgets**:
   ```dart
   // Old
   TextFormField(decoration: ...)
   
   // New
   CustomTextField(controller: ..., label: ...)
   ```

4. **Use validators**:
   ```dart
   // Old
   validator: (value) { if (value.isEmpty) ... }
   
   // New
   validator: FormValidators.email
   ```

## 📈 Benefits Achieved

1. **Maintainability**: Clear separation of concerns
2. **Testability**: Easy to mock and test
3. **Scalability**: Add features without breaking existing code
4. **Reusability**: DRY components used across screens
5. **Flexibility**: Swap implementations easily
6. **Type Safety**: Strong typing with domain models
7. **Documentation**: Self-documenting code with clear names
8. **Error Handling**: Consistent error management

## 🔄 Future Enhancements

1. **State Management**: Add BLoC or Riverpod
2. **Offline Support**: Cache with Hive or SQLite
3. **Biometric Auth**: Add fingerprint/face ID
4. **Social Auth**: Google, Facebook sign-in
5. **Rate Limiting**: Prevent brute force attacks
6. **Analytics**: Track auth events
7. **A/B Testing**: Test different auth flows

## 📞 Support

For questions or issues, contact the development team or refer to:
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Flutter Documentation](https://flutter.dev/docs)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
