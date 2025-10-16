# Kindred - AI Chatbot App

An intelligent AI-powered chatbot application built with Flutter and Firebase, featuring real-time conversations, voice input/output, and persistent chat history. The project integrates Firebase services and a configurable AI backend (see `lib/services/ai_service.dart`).

## Features

- 🔐 **Secure Authentication**: Email/Password and Google OAuth
- 💬 **AI-Powered Chat**: Real-time conversations using Firebase AI (Gemini)
- 🎤 **Voice Input/Output**: Speech-to-text and text-to-speech capabilities
- 💾 **Persistent Storage**: Chat history saved in Firestore
- 🔄 **Offline Support**: Local caching with Firestore offline persistence
- 📱 **Cross-Platform**: Native Material Design for Android and Cupertino for iOS
- ⚡ **Real-Time Sync**: Instant message synchronization across devices

## Screenshots

Screenshots coming soon.

## Architecture

```
lib/
├── models/          # Data models
├── services/        # Business logic & API calls
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── utils/          # Helper functions & constants
```

### Tech Stack

- **Frontend**: Flutter (stable)
- **Dart SDK**: >= 3.9.2 (see `pubspec.yaml`)
- **Backend**: Firebase (Auth, Firestore, Analytics) and optional Google/Vertex AI via the `firebase_ai` package
- **State Management**: Provider
- **AI Model**: Gemini family (configurable in `lib/services/ai_service.dart`)
- **Voice**: `speech_to_text`, `flutter_tts`

## Getting Started

### Prerequisites

- Flutter (stable) and a working Flutter toolchain
- Dart SDK >= 3.9.2 (enforced in `pubspec.yaml`)
- Firebase CLI / FlutterFire CLI (optional but recommended for multi-platform configuration)
- Android Studio / Xcode for platform builds
- (Optional) Google Cloud project with Vertex AI enabled if you plan to call Vertex models directly

### Installation

1. **Clone the repository**

```powershell
git clone https://github.com/AvishkaGihan/kindred_chatbot.git
cd kindred_chatbot
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

If this is a fresh checkout, configure Firebase for platforms you plan to run on:

- Android: this repo already contains `android/app/google-services.json` (check the file in the repo). For other platforms run `flutterfire configure` or provide your platform config files (`GoogleService-Info.plist` for iOS/macOS).

```powershell
# Install FlutterFire CLI (if needed)
dart pub global activate flutterfire_cli

# Interactive config (optional)
flutterfire configure
```

4. **Enable Firebase / Google Cloud Services**

- Firebase Authentication (Email/Password, Google)
- Cloud Firestore
- (Optional) Vertex AI / Google Cloud AI if you plan to use Vertex models directly. See `docs/API_INTEGRATION.md` for Vertex AI setup and service account guidance.

5. **Update Firestore Security Rules**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /chats/{chatId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

6. **Run the app**

```bash
# Run on emulator/device
flutter run

# Run in release mode
flutter run --release
```

## Building for Production

### Android (APK)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
# Then use Xcode to archive and upload to TestFlight
```

### Configuration

See `docs/API_INTEGRATION.md` for in-depth configuration of Vertex AI and Firebase AI. The AI model and generation settings are configurable in `lib/services/ai_service.dart` — edit that file to change model name and generation parameters (temperature, token limits, etc.).

## Project Structure

```
kindred_chatbot/
├── android/              # Android native code (contains google-services.json)
├── ios/                  # iOS native code
├── lib/
│   ├── main.dart        # App entry point
│   ├── firebase_options.dart # Generated Firebase config (present in repo)
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── screens/         # UI screens
│   ├── services/        # Business logic
│   ├── utils/           # Utilities
│   └── widgets/         # Reusable widgets
├── test/                # Unit & widget tests
├── assets/              # Images & resources
└── pubspec.yaml         # Dependencies
```

## Features Implementation

### Authentication Flow

1. User signs in with email/password or Google
2. Firebase Auth creates user session
3. User document created in Firestore
4. Redirected to chat screen

### Chat Flow

1. User sends message
2. Message saved to Firestore
3. Firebase AI processes message
4. AI response received and saved
5. Real-time UI update via StreamBuilder

### Voice Features

- **Speech-to-Text**: Uses `speech_to_text` package
- **Text-to-Speech**: Uses `flutter_tts` package
- Permissions handled automatically

## Troubleshooting

### Common Issues

**1. Firebase Configuration Error**

```powershell
# Reconfigure Firebase (force)
flutterfire configure --force
```

**2. Firebase AI Not Enabled**

- Go to Firebase Console
- Enable Firebase AI in your project
- Wait a few minutes for propagation

**3. Voice Input Not Working**

- Check microphone permissions
- Ensure device has microphone
- Test on physical device (not emulator)

**4. Build Failures**

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Best Practices

1. **Error Handling**: All services include try-catch blocks
2. **Loading States**: Show progress indicators during async operations
3. **Offline Support**: Firestore automatically caches data
4. **Security**: Never expose API keys in client code
5. **Testing**: Run tests before each release

```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google for Vertex AI and Gemini models

## Contact

Avishka Gihan

Project Link: https://github.com/AvishkaGihan/kindred_chatbot
