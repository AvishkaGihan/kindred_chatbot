import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/voice_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/chat_shimmer.dart';
import '../models/message_model.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final voiceProvider = Provider.of<VoiceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryBlueVariant],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kindred',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Voice button with enhanced functionality
          _buildVoiceButton(voiceProvider, chatProvider),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatHistoryScreen(),
                ),
              );
            },
            tooltip: 'Chat History',
          ),
          // User profile avatar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                backgroundImage: authProvider.user?.photoURL != null
                    ? NetworkImage(authProvider.user!.photoURL!)
                    : null,
                child: authProvider.user?.photoURL == null
                    ? const Icon(Icons.person, size: 20, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Show recognized text while listening
          if (voiceProvider.recognizedText.isNotEmpty)
            _buildRecognizedTextBanner(voiceProvider),

          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatProvider.messagesStream,
              builder: (context, snapshot) {
                // Show shimmer on initial load only
                if (chatProvider.isInitialLoading &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const ChatShimmer();
                }

                // Handle errors
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty && !chatProvider.isProcessing) {
                  return _buildEmptyState(context);
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      messages.length + (chatProvider.isProcessing ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show typing indicator as last item when processing
                    if (index == messages.length && chatProvider.isProcessing) {
                      return _buildTypingIndicator();
                    }
                    final message = messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          ChatInput(
            onSendMessage: (text) {
              chatProvider.sendMessage(text);
            },
            isProcessing: chatProvider.isProcessing,
            onMicPressed: () async {
              if (voiceProvider.isListening) {
                voiceProvider.stopListening();
              } else {
                await voiceProvider.startListeningWithChat(chatProvider);
              }
            },
            isListening: voiceProvider.isListening,
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton(
    VoiceProvider voiceProvider,
    ChatProvider chatProvider,
  ) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            voiceProvider.isListening ? Icons.mic_off : Icons.mic,
            color: voiceProvider.isListening
                ? AppTheme.errorColor
                : Colors.white,
          ),
          onPressed: () async {
            if (voiceProvider.isListening) {
              voiceProvider.stopListening();
            } else {
              await voiceProvider.startListeningWithChat(chatProvider);
            }
          },
        ),
        if (voiceProvider.isProcessingVoice)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecognizedTextBanner(VoiceProvider voiceProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      color: Colors.blue.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.mic, size: 16, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Recognized: ${voiceProvider.recognizedText}',
              style: TextStyle(color: Colors.blue, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withValues(alpha: 0.1),
                          AppTheme.primaryBlueVariant.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Start a conversation',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ask me anything or tap the microphone\nto use voice input',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip(
                  context,
                  'Tell me a story',
                  Icons.auto_stories,
                ),
                _buildSuggestionChip(context, 'Help me code', Icons.code),
                _buildSuggestionChip(
                  context,
                  'Explain a concept',
                  Icons.lightbulb_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () {
        chatProvider.sendMessage(label);
      },
      backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
      side: BorderSide(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animationValue = ((value + delay) % 1.0);
        final opacity =
            0.3 +
            (0.7 *
                (0.5 +
                    0.5 *
                        (animationValue > 0.5
                            ? 1 - animationValue
                            : animationValue) *
                        2));

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
