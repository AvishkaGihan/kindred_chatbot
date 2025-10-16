# Kindred Architecture Documentation

## Overview

Kindred follows a layered architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Screens, Widgets, UI Components)  │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│        State Management Layer       │
│         (Provider Pattern)          │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│         Business Logic Layer        │
│      (Services, Use Cases)          │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│           Data Layer                │
│  (Firebase, Local Storage, Models)  │
└─────────────────────────────────────┘
```

## Directory Structure

```text
lib/
├── main.dart                       # App entry point
├── firebase_options.dart           # Generated Firebase config
├── models/                         # Data models
│   ├── user_model.dart
│   ├── message_model.dart
│   └── chat_session_model.dart
├── providers/                      # State management (Provider)
│   ├── auth_provider.dart
│   └── chat_provider.dart
├── screens/                        # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
+│   │   └── register_screen.dart
│   ├── chat/
│   │   ├── chat_screen.dart
│   │   └── widgets/
│   │       ├── chat_input.dart
│   │       └── message_bubble.dart
│   ├── premium_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── services/                       # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── ai_service.dart
│   ├── voice_service.dart
│   ├── cache_service.dart
│   ├── analytics_service.dart
│   └── subscription_service.dart
├── utils/                          # Utilities
│   ├── constants.dart
│   └── helpers.dart
└── widgets/                        # Reusable widgets
    ├── optimized_image.dart
    ├── loading_widget.dart
    └── error_widget.dart
```

Design Patterns

1. Provider Pattern (State Management)

Purpose: Manage app state reactively using `ChangeNotifier` providers registered at the top of the widget tree (check `lib/main.dart`).

Implementation (simplified):

```dart
class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }
}
```

Usage example:

```dart
// In a widget
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.user?.email ?? 'Not logged in');
  },
)
```

2. Service Pattern

Purpose: Encapsulate integrations and business logic (see `lib/services/`). Services are thin wrappers around Firebase or other SDKs and are consumed by providers and UI code.

Implementation (simplified):

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
```

3. Repository / Data Layer

Purpose: Abstract data sources (Firestore, local cache). `FirestoreService` centralizes reads/writes for chat and user data.

Example (simplified):

```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessage(String userId, String chatId, Message message) async {
    await _firestore
      .collection('users')
      .doc(userId)
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(message.id)
      .set(message.toJson());
  }
}
```

```

## Data Flow

### Authentication Flow

```

User Action (Login)
↓
LoginScreen
↓
AuthProvider.signIn()
↓
AuthService.signInWithEmail()
↓
Firebase Auth
↓
User Object Returned
↓
AuthProvider updates state
↓
UI rebuilds
↓
Navigate to ChatScreen

```

### Chat Message Flow

```

User types message
↓
ChatInput widget
↓
ChatProvider.sendMessage()
↓

1. Save to Firestore (FirestoreService)
2. Send to AI (AIService)
   ↓
   AI response received
   ↓
   Save AI response to Firestore
   ↓
   StreamBuilder updates UI
   ↓
   Message bubbles rendered
   State Management
   Global State (Provider)

AuthProvider: User authentication state
ChatProvider: Chat messages and sessions

Local State (StatefulWidget)

Form inputs
UI animations
Temporary UI state

Error Handling Strategy
Levels of Error Handling

Service Level: Catch and throw meaningful errors

darttry {
await \_auth.signIn(email, password);
} on FirebaseAuthException catch (e) {
throw AuthException(e.code);
}

Provider Level: Convert errors to user-friendly messages

darttry {
await \_authService.signIn(email, password);
} catch (e) {
\_errorMessage = 'Login failed: ${e.toString()}';
notifyListeners();
}

UI Level: Display errors to user

dartif (authProvider.errorMessage != null) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(authProvider.errorMessage!)),
);
}

```

## Security Considerations

### 1. Data Encryption

- All network traffic uses HTTPS/TLS
- Firebase handles data encryption at rest
- User credentials never stored locally

### 2. Authentication

- Firebase Authentication tokens
- Automatic token refresh
- Secure session management

### 3. Authorization

- Firestore security rules enforce user access
- Server-side validation for all operations
- No sensitive data in client code

### 4. API Keys

- Firebase configuration is generated into `lib/firebase_options.dart` (this repo includes a generated file). Treat that file as configuration rather than a secrets store; keep production secrets and service account keys out of source control.
- Platform-specific configuration files (`google-services.json`, `GoogleService-Info.plist`) are used for mobile builds.
- No hardcoded secrets in application code; use environment variables or secret managers for server-side credentials.

## Performance Optimizations

### 1. Lazy Loading

- Messages loaded in batches
- Pagination for chat history
- On-demand asset loading

### 2. Caching

- Local message caching
- Firestore offline persistence
- Image caching with CachedNetworkImage

### 3. Memory Management

- Dispose controllers and listeners
- Stream subscriptions properly closed
- Efficient widget rebuilds with Consumer

### 4. Network Optimization

- Batch Firestore operations
- Minimize real-time listeners
- Compress data when possible

## Testing Strategy

### Unit Tests

- Service layer logic
- Model conversions
- Utility functions

### Widget Tests

- Individual widget rendering
- User interactions
- State updates

### Integration Tests

- Complete user flows
- Firebase integration
- E2E scenarios

## Scalability Considerations

### Current Limitations

- Message pagination limit: the client uses a default page size of 50 messages (`_messageLimit = 50` in `lib/providers/chat_provider.dart`). This is configurable but set as a sensible default.
- Offline: Firestore offline persistence is enabled for basic offline reads/writes, but complex sync/conflict resolution is not implemented.


### Future Enhancements

- Message pagination
- Cloud Functions for backend logic
- CDN for static assets
- Database indexing optimization
```
