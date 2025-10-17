import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../utils/version_config.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/optimized_image.dart';
import '../auth/login_screen.dart';
import '../premium_screen.dart';
import '../settings/settings_screen.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/theme/app_dimensions.dart';
import '../../widgets/snackbar/custom_snackbar.dart';
import '../../utils/animations/hero_tags.dart';
import '../../utils/animations/page_transitions.dart';
import '../../widgets/premium/premium_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  int _calculateTotalMessages(ChatProvider chatProvider) {
    return chatProvider.messages.length;
  }

  int _calculateDaysActive(ChatProvider chatProvider) {
    if (chatProvider.sessions.isEmpty) return 0;

    final oldestSession = chatProvider.sessions.reduce(
      (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
    );
    return DateTime.now().difference(oldestSession.createdAt).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: user == null
          ? const LoadingWidget(message: 'Loading profile...')
          : CustomScrollView(
              slivers: [
                // Hero header with gradient
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      AppColors.primaryBlueDark,
                                      AppColors.primaryBlue,
                                      AppColors.secondaryTeal,
                                    ]
                                  : [
                                      AppColors.primaryBlue,
                                      AppColors.primaryBlueLight,
                                      AppColors.secondaryTeal,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),

                        // Profile content
                        SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(height: 60),

                              // Profile picture with premium badge
                              Hero(
                                tag: HeroTags.profilePicture,
                                child: PremiumBadgeOverlay(
                                  isPremium: subscriptionProvider.isPremium,
                                  badgeSize: 24,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: user.photoURL != null
                                        ? ClipOval(
                                            child: OptimizedImage(
                                              imageUrl: user.photoURL!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.white,
                                            child: Text(
                                              user.displayName
                                                      ?.substring(0, 1)
                                                      .toUpperCase() ??
                                                  'U',
                                              style: TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingMd),

                              // Name
                              Text(
                                user.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacing2xs),

                              // Email
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingLg),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistics cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Messages',
                                _calculateTotalMessages(
                                  chatProvider,
                                ).toString(),
                                Icons.message_rounded,
                                AppColors.primaryBlue,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Sessions',
                                chatProvider.sessions.length.toString(),
                                Icons.chat_bubble_rounded,
                                AppColors.secondaryTeal,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Days Active',
                                _calculateDaysActive(chatProvider).toString(),
                                Icons.calendar_today_rounded,
                                AppColors.success,
                                isDark,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spacingXl),

                        // Premium promotion card
                        _buildPremiumCard(context, isDark),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // Menu section
                        _buildSectionTitle(context, 'Account', isDark),
                        _buildMenuCard(
                          context,
                          isDark,
                          children: [
                            _buildMenuTile(
                              context,
                              'Chat History',
                              Icons.history_rounded,
                              () {
                                _showChatHistory(
                                  context,
                                  chatProvider,
                                  user.uid,
                                  isDark,
                                );
                              },
                              isDark,
                            ),
                            _buildDivider(isDark),
                            _buildMenuTile(
                              context,
                              'Settings',
                              Icons.settings_rounded,
                              () {
                                Navigator.of(context).push(
                                  PageTransitions.slideFromRight(
                                    const SettingsScreen(),
                                  ),
                                );
                              },
                              isDark,
                            ),
                            _buildDivider(isDark),
                            _buildMenuTile(
                              context,
                              'About',
                              Icons.info_rounded,
                              () {
                                _showAboutDialog(context);
                              },
                              isDark,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // Danger zone
                        _buildSectionTitle(context, 'Danger Zone', isDark),
                        _buildMenuCard(
                          context,
                          isDark,
                          children: [
                            _buildMenuTile(
                              context,
                              'Delete Account',
                              Icons.delete_forever_rounded,
                              () {
                                _showDeleteAccountDialog(context, authProvider);
                              },
                              isDark,
                              isDestructive: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // Sign out button
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightMd,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await authProvider.signOut();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariantLight,
                              foregroundColor: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
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
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: AppDimensions.iconMd, color: color),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacing2xs),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.spacing2xs,
        bottom: AppDimensions.spacingSm,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    bool isDark, {
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
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildPremiumCard(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(PageTransitions.scale(const PremiumScreen()));
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC107), Color(0xFFFF6F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFC107).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: AppDimensions.iconLg,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing2xs),
                  Text(
                    'Unlock unlimited features & priority support',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: AppDimensions.iconSm,
            ),
          ],
        ),
      ),
    );
  }

  void _showChatHistory(
    BuildContext context,
    ChatProvider chatProvider,
    String userId,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.spacingSm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),

            // List
            Expanded(
              child: chatProvider.sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 64,
                            color: isDark
                                ? AppColors.textHintDark
                                : AppColors.textHintLight,
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          Text(
                            'No chat history yet',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.paddingMd),
                      itemCount: chatProvider.sessions.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppDimensions.spacingSm),
                      itemBuilder: (context, index) {
                        final session = chatProvider.sessions[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingMd,
                              vertical: AppDimensions.spacingXs,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.spacingSm,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            title: Text(
                              session.title,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Last updated: ${_formatDate(session.lastUpdated)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmation(
                                      context,
                                      chatProvider,
                                      userId,
                                      session.id,
                                      isDark,
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              chatProvider.loadChatSession(userId, session.id);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ChatProvider chatProvider,
    String userId,
    String sessionId,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            const Text('Delete Chat'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this chat session? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await chatProvider.deleteSession(userId, sessionId);
              if (context.mounted) {
                Navigator.pop(context);
                CustomSnackbar.showSuccess(
                  context,
                  message: 'Chat session deleted',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: AppDimensions.iconMd,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.\n\nAre you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Implement account deletion
              Navigator.pop(context);
              CustomSnackbar.showInfo(
                context,
                message: 'Account deletion is not yet implemented',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete My Account'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Kindred',
      applicationVersion: VersionConfig.fullVersion,
      applicationIcon: const Icon(Icons.chat_bubble_outline, size: 48),
      children: [
        const Text(
          'Kindred is an AI-powered chatbot built with Flutter and Firebase Vertex AI.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Real-time AI conversations\n'
          '• Voice input/output\n'
          '• Persistent chat history\n'
          '• Offline support',
        ),
        const SizedBox(height: 16),
        Text(
          'Version: ${VersionConfig.appVersion}\n'
          'Build: ${VersionConfig.buildNumber}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('h:mm a').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
