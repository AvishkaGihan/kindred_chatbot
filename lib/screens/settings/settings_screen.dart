import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildThemeSelector(context, settings),
          const Divider(height: 32),

          // Voice Settings Section
          _buildSectionHeader('Voice Settings'),
          _buildTTSToggle(context, settings),
          _buildSpeechRateSlider(context, settings),
          const Divider(height: 32),

          // Chat Settings Section
          _buildSectionHeader('Chat Settings'),
          _buildMaxMessagesSelector(context, settings),
          _buildClearHistoryTile(context, chatProvider, authProvider),
          const Divider(height: 32),

          // About Section
          _buildSectionHeader('About'),
          _buildAppVersionTile(context),
          _buildPrivacyPolicyTile(context),
          _buildTermsOfServiceTile(context),
          const Divider(height: 32),

          // Reset Settings
          _buildResetSettingsTile(context, settings),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsProvider settings) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Theme'),
      subtitle: Text(_getThemeModeName(settings.themeMode)),
      onTap: () => _showThemeDialog(context, settings),
    );
  }

  Widget _buildTTSToggle(BuildContext context, SettingsProvider settings) {
    return SwitchListTile(
      secondary: const Icon(Icons.volume_up_outlined),
      title: const Text('Text-to-Speech'),
      subtitle: const Text('Enable voice responses'),
      value: settings.isTTSEnabled,
      onChanged: (value) => settings.updateTTSEnabled(value),
    );
  }

  Widget _buildSpeechRateSlider(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.speed_outlined),
      title: const Text('Speech Rate'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${settings.speechRate.toStringAsFixed(1)}x'),
          Slider(
            value: settings.speechRate,
            min: AppConstants.minSpeechRate,
            max: AppConstants.maxSpeechRate,
            divisions: 7,
            label: '${settings.speechRate.toStringAsFixed(1)}x',
            onChanged: settings.isTTSEnabled
                ? (value) => settings.updateSpeechRate(value)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMaxMessagesSelector(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.message_outlined),
      title: const Text('Messages to Load'),
      subtitle: Text('${settings.maxMessages} messages'),
      trailing: DropdownButton<int>(
        value: settings.maxMessages,
        underline: const SizedBox(),
        items: [20, 50, 100].map((int value) {
          return DropdownMenuItem<int>(value: value, child: Text('$value'));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            settings.updateMaxMessages(value);
          }
        },
      ),
    );
  }

  Widget _buildClearHistoryTile(
    BuildContext context,
    ChatProvider chatProvider,
    AuthProvider authProvider,
  ) {
    return ListTile(
      leading: const Icon(Icons.delete_outline),
      title: const Text('Clear Chat History'),
      subtitle: const Text('Delete all chat sessions'),
      onTap: () => _showClearHistoryDialog(context, chatProvider, authProvider),
    );
  }

  Widget _buildAppVersionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('App Version'),
      subtitle: Text(
        '${AppConstants.appVersion} (${AppConstants.buildNumber})',
      ),
    );
  }

  Widget _buildPrivacyPolicyTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: const Text('Privacy Policy'),
      trailing: const Icon(Icons.open_in_new, size: 20),
      onTap: () => _launchURL(
        context,
        'https://github.com/AvishkaGihan/kindred_chatbot/blob/main/PRIVACY_POLICY.md',
      ),
    );
  }

  Widget _buildTermsOfServiceTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text('Terms of Service'),
      trailing: const Icon(Icons.open_in_new, size: 20),
      onTap: () => _launchURL(
        context,
        'https://github.com/AvishkaGihan/kindred_chatbot/blob/main/TERMS_OF_SERVICE.md',
      ),
    );
  }

  Widget _buildResetSettingsTile(
    BuildContext context,
    SettingsProvider settings,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showResetDialog(context, settings),
        icon: const Icon(Icons.restore),
        label: const Text('Reset to Defaults'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Light'),
                trailing: settings.themeMode == ThemeMode.light
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  settings.updateThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Dark'),
                trailing: settings.themeMode == ThemeMode.dark
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  settings.updateThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('System Default'),
                trailing: settings.themeMode == ThemeMode.system
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  settings.updateThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearHistoryDialog(
    BuildContext context,
    ChatProvider chatProvider,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Chat History?'),
          content: const Text(
            'This will delete all your chat sessions and messages. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (authProvider.user != null) {
                  await chatProvider.clearAllChatHistory(
                    authProvider.user!.uid,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chat history cleared successfully'),
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Settings?'),
          content: const Text(
            'This will reset all settings to their default values.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await settings.resetToDefaults();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset to defaults')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }
}
