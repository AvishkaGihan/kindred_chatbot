import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/typing_indicator.dart';
import '../profile/profile_screen.dart';
import '../premium_screen.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/theme/app_dimensions.dart';
import '../../utils/theme/app_animations.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomFAB = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    // FAB animation
    _fabController = AnimationController(
      duration: AppAnimations.durationNormal,
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: AppAnimations.curveSmooth,
    );

    // Scroll listener for FAB
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final isAtBottom =
        _scrollController.offset >=
        _scrollController.position.maxScrollExtent - 100;

    if (!isAtBottom && !_showScrollToBottomFAB) {
      setState(() => _showScrollToBottomFAB = true);
      _fabController.forward();
    } else if (isAtBottom && _showScrollToBottomFAB) {
      _fabController.reverse().then((_) {
        if (mounted) {
          setState(() => _showScrollToBottomFAB = false);
        }
      });
    }
  }

  void _initializeChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      await chatProvider.initialize(
        authProvider.user!.uid,
        speechRate: settingsProvider.speechRate,
        maxMessages: settingsProvider.maxMessages,
      );

      // Update chat provider when settings change
      chatProvider.updateSettings(
        ttsEnabled: settingsProvider.isTTSEnabled,
        speechRate: settingsProvider.speechRate,
        maxMessages: settingsProvider.maxMessages,
      );

      if (chatProvider.currentSessionId == null) {
        await chatProvider.createNewSession(authProvider.user!.uid);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date); // e.g., "Monday"
    } else {
      return DateFormat('MMM d, yyyy').format(date); // e.g., "Jan 15, 2024"
    }
  }

  bool _shouldShowDateSeparator(int index, List messages) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final currentDate = currentMessage.timestamp;
    final previousDate = previousMessage.timestamp;

    return currentDate.year != previousDate.year ||
        currentDate.month != previousDate.month ||
        currentDate.day != previousDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    // Auto-scroll when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatProvider.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Kindred'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.star_fill,
                  color: CupertinoColors.systemYellow,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const PremiumScreen(),
                    ),
                  );
                },
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.person_circle),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        child: _buildChatBody(authProvider, chatProvider),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.primaryBlueDark, AppColors.primaryBlue]
                  : [AppColors.primaryBlue, AppColors.primaryBlueLight],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingXs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: AppDimensions.iconMd,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            const Text(
              'Kindred',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFC107), // Amber color
            ),
            tooltip: 'Upgrade to Premium',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'new_chat' && authProvider.user != null) {
                await chatProvider.createNewSession(authProvider.user!.uid);
              } else if (value == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_chat',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: AppDimensions.spacingSm),
                    Text('New Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: AppDimensions.spacingSm),
                    Text('Profile'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildChatBody(authProvider, chatProvider),
      floatingActionButton: _showScrollToBottomFAB
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: AppColors.primaryBlue,
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildChatBody(AuthProvider authProvider, ChatProvider chatProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: chatProvider.messages.isEmpty
              ? _buildEmptyState(isDark, authProvider, chatProvider)
              : RefreshIndicator(
                  color: AppColors.primaryBlue,
                  onRefresh: () async {
                    if (authProvider.user != null &&
                        chatProvider.currentSessionId != null &&
                        chatProvider.hasMore) {
                      await chatProvider.loadMoreMessages(
                        authProvider.user!.uid,
                        chatProvider.currentSessionId!,
                      );
                    }
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMd,
                      vertical: AppDimensions.paddingSm,
                    ),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      final showDateSeparator = _shouldShowDateSeparator(
                        index,
                        chatProvider.messages,
                      );

                      return Column(
                        children: [
                          if (showDateSeparator)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingMd,
                              ),
                              child: _buildDateSeparator(
                                message.timestamp,
                                isDark,
                              ),
                            ),
                          MessageBubble(
                            message: message,
                            onSpeak: () {
                              chatProvider.speakMessage(message.content);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
        ),
        if (chatProvider.isLoading) const TypingIndicator(),
        ChatInput(
          onSendMessage: (message) async {
            if (authProvider.user != null) {
              await chatProvider.sendMessage(authProvider.user!.uid, message);
            }
          },
          onVoiceInput: () async {
            await chatProvider.startVoiceInput((text) async {
              if (authProvider.user != null && text.isNotEmpty) {
                await chatProvider.sendMessage(authProvider.user!.uid, text);
              }
            });
          },
          isListening: chatProvider.isListening,
          isLoading: chatProvider.isLoading,
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    AuthProvider authProvider,
    ChatProvider chatProvider,
  ) {
    final conversationStarters = [
      {'icon': Icons.psychology, 'text': 'How can I improve my mental health?'},
      {'icon': Icons.self_improvement, 'text': 'Tips for managing stress'},
      {'icon': Icons.wb_sunny, 'text': 'How to start my day positively'},
      {'icon': Icons.favorite, 'text': 'Building healthy relationships'},
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.2),
                    AppColors.secondaryTeal.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: isDark
                    ? AppColors.primaryBlueLight
                    : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'Start a conversation',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Choose a conversation starter or ask anything',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            ...conversationStarters.map((starter) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                child: InkWell(
                  onTap: () async {
                    if (authProvider.user != null) {
                      await chatProvider.sendMessage(
                        authProvider.user!.uid,
                        starter['text'] as String,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMd),
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                            AppDimensions.spacingSm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                          ),
                          child: Icon(
                            starter['icon'] as IconData,
                            color: AppColors.primaryBlue,
                            size: AppDimensions.iconSm,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: Text(
                            starter['text'] as String,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: AppDimensions.iconXs,
                          color: isDark
                              ? AppColors.textHintDark
                              : AppColors.textHintLight,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSm,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSm,
              vertical: AppDimensions.spacing2xs,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Text(
              _formatDate(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ],
    );
  }
}
