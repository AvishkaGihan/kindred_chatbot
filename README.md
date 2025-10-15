# Kindred - AI Chatbot App

An intelligent AI-powered chatbot application built with Flutter and Firebase AI, featuring real-time conversations, voice input/output, and persistent chat history.

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

- **Frontend**: Flutter 3.35+ (Dart 3.9+)
- **Backend**: Firebase (Auth, Firestore, AI)
- **State Management**: Provider
- **AI Model**: Google Gemini 2.5 Flash
- **Voice**: speech_to_text, flutter_tts

## Getting Started

### Prerequisites

- Flutter SDK 3.35 or higher
- Dart 3.9 or higher
- Firebase CLI
- Android Studio / Xcode
- Google Cloud Project with Firebase AI enabled

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/AvishkaGihan/kindred-chatbot.git
cd kindred-chatbot
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

4. **Enable Firebase Services**

   - Firebase Authentication (Email/Password, Google)
   - Cloud Firestore
   - Firebase AI

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

## Configuration

### Firebase AI Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Enable Firebase AI in your project
3. The app uses `gemini-2.5-flash` model by default

### Customizing AI Responses

Edit `lib/services/ai_service.dart`:

```dart
final ai = FirebaseAI.googleAI();
_model = ai.generativeModel(
  model: 'gemini-2.5-flash',
  generationConfig: GenerationConfig(
    temperature: 0.7,  // Adjust creativity (0.0 - 1.0)
    maxOutputTokens: 1000,  // Adjust response length
  ),
);
```

## Project Structure

```
kindred_chatbot/
├── android/              # Android native code
├── ios/                  # iOS native code
├── lib/
│   ├── main.dart        # App entry point
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

```bash
# Reconfigure Firebase
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

Project Link: [https://github.com/AvishkaGihan/kindred-chatbot](https://github.com/AvishkaGihan/kindred-chatbot)

## Demo

📹 **Demo Video**: Coming soon

🌐 **Try TestFlight Beta**: Coming soon
