#!/bin/bash

# Kindred iOS Deployment Script
# This script builds and prepares the iOS app for release

set -e  # Exit on error

echo "🚀 Starting Kindred Chatbot iOS Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project-specific variables
PROJECT_NAME="kindred_chatbot"
APP_NAME="Kindred Chatbot"
FIREBASE_PROJECT="kindred-chatbot"
IOS_BUNDLE_ID="com.example.kindred-chatbot"

# Check if running on macOS
if [[ "${OSTYPE}" != "darwin"* ]]; then
    echo -e "${RED}❌ iOS builds require macOS${NC}"
    exit 1
fi

# Check Flutter installation
echo "📱 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
cd ios && pod deintegrate && pod install && cd ..

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate launcher icons
echo "🎨 Generating launcher icons..."
flutter pub run flutter_launcher_icons:main

# Verify Firebase configuration
echo "🔥 Verifying Firebase configuration for iOS..."
if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo -e "${RED}❌ Missing GoogleService-Info.plist file${NC}"
    exit 1
fi

# Verify required permissions for speech features
echo "🎤 Verifying microphone permissions..."
if ! grep -q "NSMicrophoneUsageDescription" ios/Runner/Info.plist; then
    echo -e "${RED}❌ Missing NSMicrophoneUsageDescription in Info.plist${NC}"
    exit 1
fi

if ! grep -q "NSSpeechRecognitionUsageDescription" ios/Runner/Info.plist; then
    echo -e "${RED}❌ Missing NSSpeechRecognitionUsageDescription in Info.plist${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Required permissions found in Info.plist${NC}"

# Run specific project tests
echo "🧪 Running tests..."
echo "Running unit tests..."
flutter test test/services/auth_service_test.dart || {
    echo -e "${RED}❌ Auth service tests failed. Fix issues before deploying.${NC}"
    exit 1
}

flutter test test/widgets/message_bubble_test.dart || {
    echo -e "${RED}❌ Message bubble tests failed. Fix issues before deploying.${NC}"
    exit 1
}

echo "Running all tests..."
flutter test || {
    echo -e "${RED}❌ Some tests failed. Fix issues before deploying.${NC}"
    exit 1
}

# Note: Integration tests require a connected device or simulator
echo "⚠️  Integration tests available but require connected device"
echo "To run integration tests: flutter test integration_test/"

# Build iOS with optimizations for Kindred Chatbot
echo "🏗️  Building iOS release for $APP_NAME..."
flutter build ios --release --no-codesign

echo ""
echo -e "${GREEN}✅ $APP_NAME iOS build complete!${NC}"
echo ""
echo "📊 Project Information:"
echo "App Name: $APP_NAME"
echo "Bundle ID: $IOS_BUNDLE_ID"
echo "Firebase Project: $FIREBASE_PROJECT"
echo ""
echo "⚠️  IMPORTANT - Before releasing to production:"
echo "1. Update Bundle Identifier from example domain to your own"
echo "2. Configure proper iOS signing certificates and provisioning profiles"
echo "3. Test Firebase features (Auth, Firestore, Analytics, Crashlytics)"
echo "4. Verify permissions for microphone (Speech-to-Text) in Info.plist"
echo ""
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select proper development team and signing"
echo "3. Update Bundle Identifier if needed"
echo "4. Select 'Any iOS Device (arm64)' as target"
echo "5. Test Firebase integration, Google Sign-In, Speech-to-Text features"
echo "6. Product -> Archive"
echo "7. Upload to App Store Connect"
echo "8. Submit for TestFlight/App Store review"
