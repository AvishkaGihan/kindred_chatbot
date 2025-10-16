#!/bin/bash

# Kindred Android Deployment Script
# This script builds and prepares the Android app for release

set -e  # Exit on error

echo "🚀 Starting Kindred Chatbot Android Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project-specific variables
PROJECT_NAME="kindred_chatbot"
APP_NAME="Kindred Chatbot"
FIREBASE_PROJECT="kindred-chatbot"

# Check Flutter installation
echo "📱 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf build/

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate launcher icons
echo "🎨 Generating launcher icons..."
flutter pub run flutter_launcher_icons:main

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

# Note: Integration tests require a connected device or emulator
echo "⚠️  Integration tests available but require connected device"
echo "To run integration tests: flutter test integration_test/"

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze || {
    echo -e "${YELLOW}⚠️  Code analysis has warnings. Review before continuing.${NC}"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
}

# Verify Firebase configuration
echo "🔥 Verifying Firebase configuration..."
if [ ! -f "android/app/google-services.json" ]; then
    echo -e "${RED}❌ Missing google-services.json file${NC}"
    exit 1
fi

# Build APK with optimizations for Kindred Chatbot
echo "🏗️  Building release APK for $APP_NAME..."
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64,android-x64

# Build App Bundle for Google Play Store
echo "📦 Building app bundle for $APP_NAME..."
flutter build appbundle --release

# Create output directory
OUTPUT_DIR="releases/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Copy builds
echo "📋 Copying builds to $OUTPUT_DIR..."
cp build/app/outputs/flutter-apk/*.apk "$OUTPUT_DIR/"
cp build/app/outputs/bundle/release/app-release.aab "$OUTPUT_DIR/"

# Get file sizes
echo ""
echo "📊 Build Information:"
echo "===================="
for file in "$OUTPUT_DIR"/*; do
    size=$(du -h "$file" | cut -f1)
    echo "$(basename "$file"): $size"
done

echo ""
echo -e "${GREEN}✅ $APP_NAME Android build complete!${NC}"
echo "📁 Files are in: $OUTPUT_DIR"
echo ""
echo "📊 Project Information:"
echo "App Name: $APP_NAME"
echo "Package: com.example.kindred_chatbot"
echo "Firebase Project: $FIREBASE_PROJECT"
echo ""
echo "⚠️  IMPORTANT - Before releasing to production:"
echo "1. Change applicationId from 'com.example.kindred_chatbot' to your domain"
echo "2. Update app signing configuration in android/app/build.gradle.kts"
echo "3. Test Firebase features (Auth, Firestore, Analytics, Crashlytics)"
echo ""
echo "Next steps:"
echo "1. Test the APK on physical devices with Firebase features"
echo "2. Verify Google Sign-In, Speech-to-Text, and TTS functionality"
echo "3. Test in-app purchases if implemented"
echo "4. Upload app-release.aab to Google Play Console"
echo "5. Submit for review"
