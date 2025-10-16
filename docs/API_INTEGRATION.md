# Kindred API Integration Guide

This document explains how Kindred Chatbot integrates with Firebase (Firestore, Auth, Analytics) and Google Vertex AI (via Firebase / Google Cloud). It includes code snippets aligned to this repository and tips for testing locally.

## Firebase & Vertex AI Integration

### Prerequisites

- A Firebase project configured for this app. The project in this repository uses generated options in `lib/firebase_options.dart` (check this file after running `flutterfire configure` or when opening the repo).
- Google Cloud project with Vertex AI enabled if you plan to use Google models directly.
- gcloud CLI (optional) for enabling APIs and managing service accounts.

### Enable required APIs (Google Cloud)

Run this once for your Google Cloud project (replace PROJECT_ID if needed):

```powershell
gcloud config set project PROJECT_ID
gcloud services enable aiplatform.googleapis.com
gcloud services enable iamcredentials.googleapis.com
```

### Configure Firebase

1. In the Firebase Console, open Project Settings → Service accounts and create a service account key if your backend or CI needs it.
2. Ensure `lib/firebase_options.dart` exists and contains your Firebase configuration (this repo includes a generated `firebase_options.dart` file from the FlutterFire CLI).

### Using the AI service in this repo

This project includes an AI service abstraction under `lib/services/ai_service.dart`. Example usage:

```dart
import 'package:kindred_chatbot/services/ai_service.dart';

final aiService = AIService();

// Send a plain message
final response = await aiService.sendMessage('Hello, AI!');
print(response.text);

// Send with conversation context (messages is a List<Message> or similar defined in the project)
final contextResponse = await aiService.sendMessageWithContext(
  'Continue our conversation',
  previousMessages,
);
```

If your project uses a different API surface, search for `AIService` under `lib/services/` and adapt the example accordingly.

### Model configuration

Model names and options depend on your Vertex/Google Cloud setup. Example generation settings (pseudo-code):

```dart
// Example generation options object used by the ai service
final config = GenerationConfig(
  temperature: 0.7, // creativity (0.0 - 1.0)
  topK: 40,
  topP: 0.95,
  maxOutputTokens: 1024,
);

// Typical choices (may change over time):
// - gemini-1.5-flash
// - gemini-1.5-pro
```

### Rate limits and billing

Rate limits depend on your Google Cloud billing and the specific model. There is no repository-enforced limit; monitor usage in the Cloud Console and set quotas as needed.

### Error handling

Catch Firebase and network errors around AI calls. Example:

```dart
try {
  final response = await aiService.sendMessage(message);
} on FirebaseException catch (e) {
  // Firebase specific errors
  // e.code can vary; inspect runtime values
  rethrow;
} catch (e) {
  // Network or parsing errors
}
```

## Firestore Integration

### Collections structure (recommended)

Kindred organizes data by user. A recommended structure used by this app looks like:

```
users/{userId}
  - email: string
  - displayName: string
  - createdAt: timestamp

  chats/{chatId}
    - title: string
    - createdAt: timestamp
    - lastUpdated: timestamp

    messages/{messageId}
      - content: string
      - role: string // e.g. 'user' | 'assistant' | 'system'
      - timestamp: timestamp
      - isError: boolean
```

Adjust field names to match the models in `lib/models/` if you customized them.

### Firestore security rules (example)

Use rules similar to the following to restrict access to document owners. Place these in `firestore.rules` or the Firebase Console Rules editor.

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read: if isOwner(userId);
      allow create: if isSignedIn();
      allow update: if isOwner(userId);

      match /chats/{chatId} {
        allow read, write: if isOwner(userId);

        match /messages/{messageId} {
          allow read, write: if isOwner(userId);
        }
      }
    }
  }
}
```

### Querying data

Example: fetch latest chats and stream messages.

```dart
// Get user's chats
final chatsQuery = FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('chats')
  .orderBy('lastUpdated', descending: true)
  .limit(20);

final chatsSnapshot = await chatsQuery.get();

// Stream messages
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('chats')
  .doc(chatId)
  .collection('messages')
  .orderBy('timestamp')
  .snapshots()
  .listen((snapshot) {
    // Handle updates
  });
```

## Authentication

This project uses Firebase Authentication with Email/Password and Google Sign-In.

### Email / Password

```dart
// Sign up
final credential = await FirebaseAuth.instance
  .createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

// Sign in
final credential = await FirebaseAuth.instance
  .signInWithEmailAndPassword(
    email: email,
    password: password,
  );
```

### Google Sign-In

```dart
// Configure Google Sign-In
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email'],
);

final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
final GoogleSignInAuthentication googleAuth =
    await googleUser!.authentication;

final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);

await FirebaseAuth.instance.signInWithCredential(credential);
```

## Voice Services

This repository includes dependencies for speech-to-text and text-to-speech (see `pubspec.yaml`): `speech_to_text` and `flutter_tts`.

### Speech-to-Text (STT)

```dart
import 'package:speech_to_text/speech_to_text.dart';

final speech = SpeechToText();

await speech.initialize();

await speech.listen(
  onResult: (result) {
    // result.recognizedWords
  },
);

await speech.stop();
```

### Text-to-Speech (TTS)

```dart
import 'package:flutter_tts/flutter_tts.dart';

final tts = FlutterTts();

await tts.setLanguage('en-US');
await tts.setSpeechRate(0.5);
await tts.setVolume(1.0);

await tts.speak('Hello, World!');
await tts.stop();
```

## How to test locally

1. Install Flutter and ensure the proper SDK listed in `pubspec.yaml` (Dart SDK >= 3.9.2).
2. Run `flutter pub get` to fetch dependencies.
3. If you haven't already, configure Firebase options (or copy `google-services.json` / `GoogleService-Info.plist`) into the platform folders. The repo contains `android/app/google-services.json`.
4. Run on a simulator or device:

```powershell
flutter run -d windows
```

Or choose `-d chrome`, an Android device, or iOS simulator depending on your platform.

5. For Vertex AI calls that require service account credentials (server-side use), create a service account key and set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable where appropriate.

## Notes and tips

- Field names and models used in this doc are the recommended defaults — confirm by scanning `lib/models/`, `lib/services/`, and `lib/providers/` for any customizations.
- The `firebase_ai` dependency in `pubspec.yaml` is used in this repo to interface with Google AI services; implementation details live under `lib/services/`.
- Keep secrets out of source control. Use CI secret managers or environment variables for production credentials.

---

If you'd like, I can also:

- add a short integration smoke test that exercises Firestore reads/writes with the emulator, or
- create a small sample that shows sending a message via `AIService` and verifying the response.
