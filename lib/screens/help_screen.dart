import 'package:flutter/material.dart';
import '../utils/theme/app_colors.dart';
import '../utils/theme/app_dimensions.dart';
import '../utils/accessibility/accessibility_utils.dart';
import '../utils/platform/platform_utils.dart';
import '../utils/constants.dart';

/// Help and support screen
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PlatformUtils.getPlatformAppBar(
        context: context,
        title: 'Help & Support',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        children: [
          // Quick Help Section
          _HelpSection(
            title: 'Quick Help',
            icon: Icons.help_outline_rounded,
            children: [
              _HelpTile(
                title: 'How to start a chat',
                description: 'Tap the chat icon and start typing your message.',
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () => _showHelpDialog(
                  context,
                  'How to start a chat',
                  'To start a new conversation:\n\n'
                      '1. Tap the chat icon in the bottom navigation\n'
                      '2. Type your message in the input field\n'
                      '3. Press send or hit Enter\n\n'
                      'The AI will respond within seconds!',
                ),
              ),
              _HelpTile(
                title: 'Voice input',
                description: 'Use voice to chat hands-free.',
                icon: Icons.mic_rounded,
                onTap: () => _showHelpDialog(
                  context,
                  'Voice input',
                  'To use voice input:\n\n'
                      '1. Tap the microphone icon in the chat input\n'
                      '2. Speak clearly when prompted\n'
                      '3. Tap stop when finished\n\n'
                      'Your speech will be converted to text automatically.',
                ),
              ),
              _HelpTile(
                title: 'Chat history',
                description: 'Access and manage your past conversations.',
                icon: Icons.history_rounded,
                onTap: () => _showHelpDialog(
                  context,
                  'Chat history',
                  'Your conversations are automatically saved.\n\n'
                      'To view history:\n'
                      '- Scroll up in any chat to see older messages\n'
                      '- Use search to find specific conversations\n\n'
                      'To delete:\n'
                      '- Long press a message\n'
                      '- Select "Delete" from the menu',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Features Section
          _HelpSection(
            title: 'Features',
            icon: Icons.auto_awesome_rounded,
            children: [
              _HelpTile(
                title: 'Premium features',
                description: 'Unlock advanced AI capabilities.',
                icon: Icons.workspace_premium_rounded,
                badge: 'Premium',
                onTap: () => _showHelpDialog(
                  context,
                  'Premium features',
                  'Premium subscription includes:\n\n'
                      '✓ Unlimited messages\n'
                      '✓ Priority response time\n'
                      '✓ Advanced AI models\n'
                      '✓ Voice chat\n'
                      '✓ Custom personality\n'
                      '✓ No ads\n\n'
                      'Tap Premium in settings to learn more.',
                ),
              ),
              _HelpTile(
                title: 'Personalization',
                description: 'Customize your AI experience.',
                icon: Icons.tune_rounded,
                onTap: () => _showHelpDialog(
                  context,
                  'Personalization',
                  'Customize your experience:\n\n'
                      '• Theme: Switch between light and dark mode\n'
                      '• AI Personality: Choose response style\n'
                      '• Language: Select your preferred language\n'
                      '• Notifications: Control alerts\n\n'
                      'Find these options in Settings.',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Account & Privacy Section
          _HelpSection(
            title: 'Account & Privacy',
            icon: Icons.lock_outline_rounded,
            children: [
              _HelpTile(
                title: 'Privacy & Security',
                description: 'How we protect your data.',
                icon: Icons.security_rounded,
                onTap: () => _showHelpDialog(
                  context,
                  'Privacy & Security',
                  'Your privacy is our priority:\n\n'
                      '• All conversations are encrypted\n'
                      '• Data is stored securely\n'
                      '• We never sell your information\n'
                      '• You can delete your data anytime\n\n'
                      'Read our full Privacy Policy in Settings.',
                ),
              ),
              _HelpTile(
                title: 'Account management',
                description: 'Manage your account settings.',
                icon: Icons.person_outline_rounded,
                onTap: () => _showHelpDialog(
                  context,
                  'Account management',
                  'Manage your account:\n\n'
                      '• Update profile information\n'
                      '• Change password\n'
                      '• Link social accounts\n'
                      '• Delete account\n\n'
                      'Access these in Profile > Settings.',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Contact Support
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Still need help?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    'Our support team is here to assist you',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  AccessibilityUtils.createAccessibleButton(
                    semanticLabel: 'Contact support',
                    semanticHint: 'Send a message to our support team',
                    enabled: true,
                    onPressed: () => _contactSupport(context),
                    child: ElevatedButton.icon(
                      onPressed: () => _contactSupport(context),
                      icon: const Icon(Icons.email_rounded),
                      label: const Text('Contact Support'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingXl,
                          vertical: AppDimensions.paddingMd,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2025 ${AppConstants.appName}. All rights reserved.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, String title, String content) {
    PlatformUtils.showPlatformDialog(
      context: context,
      title: title,
      content: content,
      confirmText: 'Got it',
    );
  }

  void _contactSupport(BuildContext context) {
    // In production, this would open email or support form
    PlatformUtils.showPlatformDialog(
      context: context,
      title: 'Contact Support',
      content:
          'Email us at: support@${AppConstants.appName.toLowerCase()}.com\n\n'
          'We typically respond within 24 hours.',
      confirmText: 'OK',
    );
  }
}

/// Help section with title and children
class _HelpSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _HelpSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSm,
            vertical: AppDimensions.paddingSm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              AccessibilityUtils.createSemanticHeader(
                label: title,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Individual help topic tile
class _HelpTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _HelpTile({
    required this.title,
    required this.description,
    required this.icon,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityUtils.createAccessibleButton(
      semanticLabel: badge != null ? '$title - $badge' : title,
      semanticHint: description,
      enabled: true,
      onPressed: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentAmber,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        onTap: onTap,
      ),
    );
  }
}
