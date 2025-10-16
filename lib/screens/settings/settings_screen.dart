import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/theme/app_dimensions.dart';
import '../../utils/theme/app_animations.dart';
import '../../widgets/snackbar/custom_snackbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _appearanceExpanded = true;
  bool _voiceExpanded = true;
  bool _chatExpanded = true;
  bool _aboutExpanded = false;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.primaryBlueDark, AppColors.primaryBlue]
                  : [AppColors.primaryBlue, AppColors.primaryBlueLight],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        children: [
          // Appearance Section
          _buildExpandableSection(
            context,
            isDark,
            icon: Icons.palette_rounded,
            title: 'Appearance',
            isExpanded: _appearanceExpanded,
            onToggle: () {
              setState(() => _appearanceExpanded = !_appearanceExpanded);
            },
            children: [_buildThemeSelector(context, settings, isDark)],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // Voice Settings Section
          _buildExpandableSection(
            context,
            isDark,
            icon: Icons.volume_up_rounded,
            title: 'Voice Settings',
            isExpanded: _voiceExpanded,
            onToggle: () {
              setState(() => _voiceExpanded = !_voiceExpanded);
            },
            children: [
              _buildTTSToggle(context, settings, isDark),
              if (settings.isTTSEnabled) ...[
                _buildDivider(isDark),
                _buildSpeechRateSlider(context, settings, isDark),
                _buildDivider(isDark),
                _buildTestVoiceButton(context, settings, chatProvider, isDark),
              ],
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // Chat Settings Section
          _buildExpandableSection(
            context,
            isDark,
            icon: Icons.chat_rounded,
            title: 'Chat Settings',
            isExpanded: _chatExpanded,
            onToggle: () {
              setState(() => _chatExpanded = !_chatExpanded);
            },
            children: [
              _buildMaxMessagesSelector(context, settings, isDark),
              _buildDivider(isDark),
              _buildClearHistoryTile(
                context,
                chatProvider,
                authProvider,
                isDark,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // About Section
          _buildExpandableSection(
            context,
            isDark,
            icon: Icons.info_rounded,
            title: 'About',
            isExpanded: _aboutExpanded,
            onToggle: () {
              setState(() => _aboutExpanded = !_aboutExpanded);
            },
            children: [
              _buildAppVersionTile(context, isDark),
              _buildDivider(isDark),
              _buildPrivacyPolicyTile(context, isDark),
              _buildDivider(isDark),
              _buildTermsOfServiceTile(context, isDark),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Reset Settings
          _buildResetSettingsTile(context, settings, isDark),
          const SizedBox(height: AppDimensions.spacingLg),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(AppDimensions.radiusMd),
              bottom: isExpanded
                  ? Radius.zero
                  : const Radius.circular(AppDimensions.radiusMd),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryBlue,
                      size: AppDimensions.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: AppAnimations.durationFast,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(children: children),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppAnimations.durationNormal,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
      indent: AppDimensions.paddingMd,
      endIndent: AppDimensions.paddingMd,
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    SettingsProvider settings,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your preferred theme',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // Theme preview cards
          Row(
            children: [
              // Light Theme
              Expanded(
                child: _buildThemeCard(
                  context,
                  isDark,
                  label: 'Light',
                  icon: Icons.light_mode_rounded,
                  isSelected: settings.themeMode == ThemeMode.light,
                  previewColor: Colors.white,
                  previewTextColor: Colors.black87,
                  onTap: () {
                    settings.updateThemeMode(ThemeMode.light);
                    CustomSnackbar.showSuccess(
                      context,
                      message: 'Theme changed to Light',
                    );
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),

              // Dark Theme
              Expanded(
                child: _buildThemeCard(
                  context,
                  isDark,
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  isSelected: settings.themeMode == ThemeMode.dark,
                  previewColor: const Color(0xFF1E1E1E),
                  previewTextColor: Colors.white,
                  onTap: () {
                    settings.updateThemeMode(ThemeMode.dark);
                    CustomSnackbar.showSuccess(
                      context,
                      message: 'Theme changed to Dark',
                    );
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),

              // System Theme
              Expanded(
                child: _buildThemeCard(
                  context,
                  isDark,
                  label: 'Auto',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: settings.themeMode == ThemeMode.system,
                  previewColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  previewTextColor: isDark ? Colors.white : Colors.black87,
                  onTap: () {
                    settings.updateThemeMode(ThemeMode.system);
                    CustomSnackbar.showSuccess(
                      context,
                      message: 'Theme set to Auto',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    bool isDark, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color previewColor,
    required Color previewTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSm),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Theme preview
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: previewColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: previewTextColor.withValues(alpha: 0.7),
                  size: AppDimensions.iconLg,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),

            // Label
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryBlue : null,
              ),
            ),

            // Checkmark
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: AppDimensions.iconXs,
                color: AppColors.primaryBlue,
              )
            else
              SizedBox(height: AppDimensions.iconXs),
          ],
        ),
      ),
    );
  }

  Widget _buildTTSToggle(
    BuildContext context,
    SettingsProvider settings,
    bool isDark,
  ) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.spacingXs,
      ),
      secondary: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: settings.isTTSEnabled
              ? AppColors.success.withValues(alpha: 0.1)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Icon(
          settings.isTTSEnabled ? Icons.volume_up : Icons.volume_off,
          color: settings.isTTSEnabled
              ? AppColors.success
              : (isDark ? AppColors.textHintDark : AppColors.textHintLight),
        ),
      ),
      title: const Text('Text-to-Speech'),
      subtitle: Text(
        settings.isTTSEnabled
            ? 'Voice responses enabled'
            : 'Voice responses disabled',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      value: settings.isTTSEnabled,
      activeThumbColor: AppColors.success,
      onChanged: (value) {
        settings.updateTTSEnabled(value);
        CustomSnackbar.showSuccess(
          context,
          message: value ? 'Voice enabled' : 'Voice disabled',
        );
      },
    );
  }

  Widget _buildSpeechRateSlider(
    BuildContext context,
    SettingsProvider settings,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Speech Rate',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingSm,
                  vertical: AppDimensions.spacing2xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${settings.speechRate.toStringAsFixed(1)}x',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Slider(
            value: settings.speechRate,
            min: AppConstants.minSpeechRate,
            max: AppConstants.maxSpeechRate,
            divisions: 7,
            label: '${settings.speechRate.toStringAsFixed(1)}x',
            activeColor: AppColors.primaryBlue,
            inactiveColor: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            onChanged: (value) {
              settings.updateSpeechRate(value);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slower',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textHintDark
                      : AppColors.textHintLight,
                ),
              ),
              Text(
                'Faster',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textHintDark
                      : AppColors.textHintLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestVoiceButton(
    BuildContext context,
    SettingsProvider settings,
    ChatProvider chatProvider,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeightMd,
        child: ElevatedButton.icon(
          onPressed: () {
            chatProvider.speakMessage(
              'Hello! This is a test of the text to speech feature at ${settings.speechRate.toStringAsFixed(1)}x speed.',
            );
            CustomSnackbar.showInfo(context, message: 'Testing voice...');
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Test Voice'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaxMessagesSelector(
    BuildContext context,
    SettingsProvider settings,
    bool isDark,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.spacingXs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Icon(Icons.message_rounded, color: AppColors.primaryBlue),
      ),
      title: const Text('Messages to Load'),
      subtitle: Text(
        'Load up to ${settings.maxMessages} messages per session',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: AppDimensions.spacing2xs,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: DropdownButton<int>(
          value: settings.maxMessages,
          underline: const SizedBox(),
          isDense: true,
          items: [20, 50, 100].map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text(
                '$value',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              settings.updateMaxMessages(value);
              CustomSnackbar.showSuccess(
                context,
                message: 'Max messages set to $value',
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildClearHistoryTile(
    BuildContext context,
    ChatProvider chatProvider,
    AuthProvider authProvider,
    bool isDark,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.spacingXs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      title: const Text('Clear Chat History'),
      subtitle: Text(
        'Delete all chat sessions',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
      ),
      onTap: () =>
          _showClearHistoryDialog(context, chatProvider, authProvider, isDark),
    );
  }

  Widget _buildAppVersionTile(BuildContext context, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.spacingXs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Icon(Icons.info_rounded, color: AppColors.primaryBlue),
      ),
      title: const Text('App Version'),
      subtitle: Text(
        '${AppConstants.appVersion} (${AppConstants.buildNumber})',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyTile(BuildContext context, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.spacingXs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Icon(Icons.privacy_tip_rounded, color: AppColors.primaryBlue),
      ),
      title: const Text('Privacy Policy'),
      trailing: Icon(
        Icons.open_in_new_rounded,
        size: AppDimensions.iconSm,
        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
      ),
      onTap: () => _launchURL(
        context,
        'https://github.com/AvishkaGihan/kindred_chatbot/blob/main/PRIVACY_POLICY.md',
      ),
    );
  }

  Widget _buildTermsOfServiceTile(BuildContext context, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.spacingXs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
        child: Icon(Icons.description_rounded, color: AppColors.primaryBlue),
      ),
      title: const Text('Terms of Service'),
      trailing: Icon(
        Icons.open_in_new_rounded,
        size: AppDimensions.iconSm,
        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
      ),
      onTap: () => _launchURL(
        context,
        'https://github.com/AvishkaGihan/kindred_chatbot/blob/main/TERMS_OF_SERVICE.md',
      ),
    );
  }

  Widget _buildResetSettingsTile(
    BuildContext context,
    SettingsProvider settings,
    bool isDark,
  ) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightMd,
      child: ElevatedButton.icon(
        onPressed: () => _showResetDialog(context, settings, isDark),
        icon: const Icon(Icons.restore_rounded),
        label: const Text('Reset to Defaults'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
    );
  }

  void _showClearHistoryDialog(
    BuildContext context,
    ChatProvider chatProvider,
    AuthProvider authProvider,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              const Text('Clear Chat History?'),
            ],
          ),
          content: const Text(
            'This will delete all your chat sessions and messages. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                if (authProvider.user != null) {
                  await chatProvider.clearAllChatHistory(
                    authProvider.user!.uid,
                  );
                  if (context.mounted) {
                    CustomSnackbar.showSuccess(
                      context,
                      message: 'Chat history cleared successfully',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(
    BuildContext context,
    SettingsProvider settings,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          title: Row(
            children: [
              Icon(
                Icons.restore_rounded,
                color: AppColors.warning,
                size: AppDimensions.iconMd,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              const Text('Reset Settings?'),
            ],
          ),
          content: const Text(
            'This will reset all settings to their default values.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await settings.resetToDefaults();
                if (context.mounted) {
                  Navigator.pop(context);
                  CustomSnackbar.showSuccess(
                    context,
                    message: 'Settings reset to defaults',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
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
