<div align="center">

# Kindred Chatbot

Your voice-enabled AI companion built with Flutter and Firebase (2025-ready).

</div>

## Overview

Kindred is a cross‑platform chat app that combines Firebase Authentication, Cloud Firestore, and Firebase AI (Gemini) to deliver a modern assistant experience. It includes:

- Multi-platform Flutter app (Android, iOS, Web; desktop optional)
- Authentication (Email/Password and Google Sign-In)
- Persistent, multi-session chat history in Firestore
- Voice input (speech-to-text) and text-to-speech playback
- Markdown rendering for rich AI responses

This repository follows 2025 best practices for Flutter, Firebase, and AI features, with clear security, privacy, and scalability guidance.

## Features

- Sign in: Email/Password, Google
- Chat sessions: create, switch, delete; auto-titled based on first message
- Realtime updates via Firestore streams
- Voice: speech-to-text capture that auto-sends to chat; text-to-speech playback
- AI replies powered by Firebase AI (Gemini 2.5 Flash Lite)
- Light/Dark theme with Material 3

## Tech Stack

- Flutter (Dart 3.9+)
- Firebase: Auth, Firestore, Firebase AI SDK
- Packages: provider, speech_to_text, flutter_tts, flutter_markdown, cached_network_image, google_sign_in

## Architecture

- Models: `MessageModel`, `ChatSession`, `UserModel`
- Services: `AuthService`, `ChatService`, `VoiceService`
- State: `AuthProvider`, `ChatProvider`, `VoiceProvider` (Provider + ChangeNotifier)
- UI: screens (`login_screen.dart`, `chat_screen.dart`, `chat_history_screen.dart`, `profile_screen.dart`) and widgets (`message_bubble.dart`, `chat_input.dart`, `loading_indicator.dart`)

Firestore data model (per user):

```
users/{userId}
	chat_sessions/{sessionId}
		messages/{messageId}
```

Rules (principle of least privilege) are defined in `firestore.rules`.

## Prerequisites

- Flutter SDK (3.24+ recommended) and Dart (3.9+)
- Android Studio / Xcode (for mobile)
- Node.js 18+ (for Firebase CLI)
- Firebase CLI and FlutterFire CLI
  - Install: `npm i -g firebase-tools` and `dart pub global activate flutterfire_cli`
- A Firebase project (Blaze recommended for AI usage; quotas apply)

## Quick start

1. Clone and install dependencies

```sh
flutter pub get
```

2. Configure Firebase

This repo already includes `firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist`. If you want to use your own Firebase project:

- Create a Firebase project and enable:
  - Authentication (Email/Password, Google)
  - Firestore (Native mode)
  - Firebase AI (Gemini access – enable in Firebase Console and accept terms)
- Android: add your app, download `google-services.json` to `android/app/`
  - Add SHA-1 and SHA-256 fingerprints for Google Sign-In
- iOS: add your app, download `GoogleService-Info.plist` to `ios/Runner/`
  - Add the reversed client ID to URL Types in Xcode (Runner target)
- Web: ensure the app is registered, or re-run FlutterFire

Regenerate local configs if needed:

```sh
flutterfire configure
```

3. Apply Firestore rules and (optional) indexes

```sh
firebase deploy --only firestore:rules
```

4. Run

```sh
flutter run
```

## Platform notes

Android

- Ensure `RECORD_AUDIO` permission is present for speech-to-text.
- Provide SHA-1/SHA-256 in Firebase Console for Google Sign-In.

iOS

- Add the following Info.plist keys with clear user-facing reasons:
  - `NSMicrophoneUsageDescription`
  - `NSSpeechRecognitionUsageDescription`
- Configure URL Types using your reversed client ID for Google Sign-In.

Web

- Add domain to Firebase Auth authorized domains.
- Google Sign-In works on web with correct OAuth client.

Desktop (Windows/macOS/Linux)

- Not all dependencies support desktop (e.g., `google_sign_in`), so desktop is optional. Voice features may require platform support.

## Environment & secrets

- Never commit private keys or service account JSON.
- Firebase client configs (web/Android/iOS) are safe to ship but restrict access with:
  - Firestore Security Rules (see `firestore.rules`)
  - Authentication enforcement (all reads/writes require the signed-in user)
  - App Check (recommended) to reduce abuse from unauthorized clients
- For Firebase AI, ensure your project has access and quotas; usage may incur costs.

## Running, linting, and tests

- Run the app: `flutter run`
- Format: `dart format .`
- Lint/typecheck: `flutter analyze`
- Tests: `flutter test`

Note: The default widget test is a template; you may want to replace it with real tests for providers and services.

## CI/CD (suggested)

GitHub Actions sample workflow (Android build + analyze + test):

```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
	build:
		runs-on: ubuntu-latest
		steps:
			- uses: actions/checkout@v4
			- uses: subosito/flutter-action@v2
				with:
					channel: stable
			- run: flutter pub get
			- run: flutter analyze
			- run: flutter test --no-pub
			- run: flutter build apk --debug
```

For releases, sign artifacts and configure Play/App Store workflows.

## Security & privacy

- Authentication required for all reads/writes; users can only access their own data (see `firestore.rules`).
- Store only necessary personal data (email, display name, photo URL). Avoid storing tokens or secrets in Firestore.
- Consider enabling App Check and rate limiting for AI endpoints.
- Document data retention and deletion policy for user requests.

## Accessibility and i18n

- Uses Material 3 with dark mode. Ensure sufficient color contrast and large tap targets.
- Voice features should provide visual feedback and alternative text input.
- Internationalization (i18n): add `flutter_localizations` and ARB files if you plan to localize.

## Troubleshooting

- Google Sign-In errors
  - Android: missing SHA-1/SHA-256 or mismatched package name.
  - iOS: missing URL Types (reversed client ID) in Xcode.
- Firestore permission denied
  - Ensure you are logged in; confirm `firestore.rules` are deployed; check `request.auth.uid`.
- Speech-to-text not working
  - Check microphone permissions and supported locales on device.
- Firebase AI errors
  - Ensure Firebase AI is enabled for your project; check billing/quota; verify the model name matches availability (we use `gemini-2.5-flash-lite`).
- Web auth popup blocked
  - Allow popups or use redirect mode for Google Sign-In.

## Folder structure

```
lib/
	models/
	providers/
	screens/
	services/
	widgets/
firebase.json
firestore.rules
firestore.indexes.json
```

## Roadmap ideas

- Streaming AI responses and typing indicators
- Attachments/images with on-device or cloud processing
- Offline caching and message resend
- Push notifications (FCM)
- App Check and enhanced telemetry

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Happy building! If you run into issues, check Troubleshooting above or open an issue with logs, platform, and Flutter/Dart versions.
