# Release Notes

# Release Notes

## Version 1.0.0 (Build 1) - 2025-10-16

### 🎉 Initial Release — Kindred Chatbot

This is the initial public release of Kindred Chatbot. It provides a lightweight, cross-platform conversational AI experience with persistent chat history, voice I/O, and Firebase-backed authentication and sync.

#### Features

- ✅ Firebase Authentication (Email/Password & Google Sign-In)
- ✅ Real-time AI chat (Google Gemini via Firebase/Vertex AI integrations)
- ✅ Voice input (speech-to-text) and text-to-speech output
- ✅ Persistent chat history stored in Firestore
- ✅ Basic offline support with local caching
- ✅ Cross-platform Material & Cupertino design
- ✅ Dark mode support
- ✅ User profile management
- ✅ Multiple chat sessions and chat history management

#### Technical details

- Flutter: 3.35.x (CI uses 3.35.6)
- Dart: 3.9.x (project SDK constraint: ^3.9.2)
- Firebase / Vertex AI (Gemini) integrations via project dependencies
- Minimum Android: 5.0 (API 21)
- Minimum iOS deployment target: 15.0

Notes:

- The Flutter SDK referenced in CI is 3.35.6 and the project requires Dart 3.9+. The `pubspec.yaml` currently pins version `1.0.0+1`.
- Some plugin artifacts and ephemeral plugin symlinks in the repo reference SDK constraints; the app targets modern Flutter/Dart as noted above.

#### Known issues

- No major issues are recorded for this release. Platform-specific warnings may appear when building with older toolchains or SDKs; if you see analyzer or build warnings, please open an issue with logs.

---

## Future roadmap

Planned improvements (high-level):

### Version 1.1.0 (Planned)

- [ ] Message search across chat history
- [ ] Export chat history (PDF / plaintext)
- [ ] Custom AI personalities and tone presets
- [ ] Image sharing and attachments in chat
- [ ] Push notifications for important events

### Version 1.2.0 (Planned)

- [ ] Group chat sessions with shared context
- [ ] Voice call / streaming audio interactions with AI
- [ ] Advanced analytics and usage dashboard (admin)
- [ ] Home screen widgets (mobile platforms)
- [ ] iPad / large-screen layout optimizations

### Version 2.0.0 (Future)

- [ ] AI image generation features
- [ ] Full multi-language support and localized models
- [ ] Custom AI training / fine-tuning workflows
- [ ] Integrations with third-party services (calendars, file storage, etc.)

If you'd like me to expand any of these items into tracked issues or draft UI/UX specs, tell me which one and I can scaffold it.
