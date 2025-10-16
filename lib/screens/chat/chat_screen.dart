import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/typing_indicator.dart';
import '../profile/profile_screen.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.user != null) {
      await chatProvider.initialize(authProvider.user!.uid);

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
    _scrollController.dispose();
    super.dispose();
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
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.person_circle),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ),
        child: _buildChatBody(authProvider, chatProvider),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kindred'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              if (authProvider.user != null) {
                await chatProvider.createNewSession(authProvider.user!.uid);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildChatBody(authProvider, chatProvider),
    );
  }

  Widget _buildChatBody(AuthProvider authProvider, ChatProvider chatProvider) {
    return Column(
      children: [
        Expanded(
          child: chatProvider.messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start a conversation',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
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
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      return MessageBubble(
                        message: message,
                        onSpeak: () {
                          chatProvider.speakMessage(message.content);
                        },
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
}
