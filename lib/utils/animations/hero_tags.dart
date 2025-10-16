/// Centralized hero animation tags to avoid conflicts
class HeroTags {
  // Profile picture tags
  static const String profilePicture = 'profile_picture';
  static const String chatProfilePicture = 'chat_profile_picture';
  static const String settingsProfilePicture = 'settings_profile_picture';

  // Premium badge tags
  static const String premiumBadge = 'premium_badge';

  // Logo tags
  static const String appLogo = 'app_logo';
  static const String splashLogo = 'splash_logo';

  // Chat message tags (use with message ID)
  static String chatMessage(String messageId) => 'chat_message_$messageId';

  // Button tags (for shared element transitions)
  static const String primaryButton = 'primary_button';
  static const String sendButton = 'send_button';

  /// Generate a unique tag with prefix
  static String generate(String prefix, String id) => '${prefix}_$id';
}
