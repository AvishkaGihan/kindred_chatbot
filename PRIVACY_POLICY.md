## Privacy Policy for Kindred

Last updated: October 16, 2025

This Privacy Policy describes how Kindred (the "App", "we", "us", or "our") — the Flutter-based AI chatbot project in the repository https://github.com/AvishkaGihan/kindred-chatbot — collects, uses, and stores your information when you use the App.

## Key contact

Primary project hub: https://github.com/AvishkaGihan/kindred-chatbot

If you need to contact the maintainers about privacy or data requests, please open an issue in the repository. If you prefer email and one has been provided by the project maintainer, that address will be listed in the repository; otherwise use the GitHub issue mechanism.

## What data we collect

1. Personal information you provide

- Email address (when you register or sign in)
- Display name
- Profile photo (if you sign in with Google)

2. Chat and AI data

- Messages and conversation history you create in the App. These are used to provide the chatbot service and are stored in Cloud Firestore unless you delete them.
- Transcripts of voice input if you use the voice input feature. The App uses the device's speech-to-text capability (via the `speech_to_text` package) to create a text transcript. Raw audio files are not stored by default; the transcript and messages may be sent to Firebase/Google AI services for processing to generate responses.

3. Device and usage data

- App usage analytics (Firebase Analytics) and crash reports (Firebase Crashlytics)
- Basic device info (platform, OS version) for diagnostics and to improve compatibility

## How we use your data

- To authenticate you (Firebase Authentication)
- To store and sync your chat history across devices (Cloud Firestore)
- To process messages with generative AI (Firebase AI / Google Gemini model)
- To provide, maintain and improve the App (analytics and crash reporting)
- To troubleshoot issues and respond to support requests

## Data storage and third-party services

The App depends on several third-party services. These are listed below with their typical role:

- Firebase (Google): Authentication (`firebase_auth`), Cloud Firestore (database), Firebase Analytics, Crashlytics, and Firebase AI for generative model calls. Data processed by Firebase is subject to Google's privacy and security practices.
- Google Sign-In (`google_sign_in`): Used to authenticate users who choose Google OAuth.
- Google Cloud / Vertex AI: The underlying AI model (e.g., Gemini) used via Firebase AI may process user messages to generate responses.
- On-device packages: `speech_to_text` and `flutter_tts` are used for voice input and text-to-speech. Speech-to-text runs on-device where supported; only the text transcript is used by the App and may be sent to AI services for processing.

## Data security

We take reasonable measures to protect your data:

- Encrypted transmission (HTTPS/TLS) for all network communication.
- Authentication and access controls provided by Firebase Auth.
- Firestore security rules expected to restrict access to authenticated users and to each user's data only.
- Crash and analytics data sent to Firebase/Google are handled according to their security practices.

Note: While we work to protect your data, no internet service or storage is completely secure. If you have specific security concerns, open an issue in the project repository so we can address them.

## Your choices and rights

Depending on your jurisdiction you may have rights such as:

- Access: Request a copy of personal data we hold about you.
- Deletion: Request deletion of your account and associated data (chat messages). Deleting your account in the App or requesting deletion via a GitHub issue will result in removal of your user record and associated Firestore documents where applicable.
- Portability: Export your chat history (you can also copy messages from the UI). If you need an export and it is not available in-app, open a GitHub issue to request assistance.
- Opt-out: You may opt-out of analytics. If you wish to opt-out, open a GitHub issue and include details about your account so we can respect your preference.

When you request account deletion we will delete your data from the App's Firestore collections where possible. Some backups or logs retained by Firebase or the App may remain for a short period as required by infrastructure retention rules.

## Data retention

- Chat messages and user data: retained until you delete them or you delete your account.
- Analytics data: Firebase Analytics default retention (up to 14 months) applies.
- Crash and diagnostic logs: retained according to Firebase Crashlytics policies.

## Children's privacy

The App is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you believe we have inadvertently collected such information, please open a GitHub issue so we can remove it.

## International transfers

Data processed by Firebase/Google may be transferred to and stored on servers located outside your country. By using the App you consent to such transfer and storage as described by Google's policies.

## Changes to this policy

We may update this Privacy Policy from time to time. We will update the "Last updated" date above when we make material changes. For significant changes we will post a notice in the project repository (or within the App if an in-app update mechanism is available).

## How to contact us

Best way to get privacy help or make a request is to open an issue on the GitHub repository:

https://github.com/AvishkaGihan/kindred-chatbot/issues

If the project maintainer adds an email contact in the repository README or project settings, that email can be used for direct requests.

## Compliance

We aim to follow common data protection frameworks where applicable, including GDPR and CCPA. This policy does not constitute legal advice. If you need specific legal assurances, consult a qualified attorney.
