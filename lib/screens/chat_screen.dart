import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/voice_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/loading_indicator.dart';
import '../models/message_model.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Kindred'),
        actions: [
          // Voice button with enhanced functionality
          _buildVoiceButton(voiceProvider, chatProvider),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatHistoryScreen()),
              );
            },
            tooltip: 'Chat History',
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingIndicator();
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Start a conversation with Kindred',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the microphone to use voice input',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
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
          ),
        ],
      ),
      // Floating action button for voice input
      floatingActionButton: _buildVoiceFAB(voiceProvider, chatProvider),
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
            color: voiceProvider.isListening ? Colors.red : null,
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

  Widget _buildVoiceFAB(
    VoiceProvider voiceProvider,
    ChatProvider chatProvider,
  ) {
    return FloatingActionButton(
      backgroundColor: voiceProvider.isListening
          ? Colors.red
          : Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      tooltip: voiceProvider.isListening
          ? 'Stop listening'
          : 'Start voice input',
      onPressed: () async {
        if (voiceProvider.isListening) {
          voiceProvider.stopListening();
        } else {
          await voiceProvider.startListeningWithChat(chatProvider);
        }
      },
      child: Icon(voiceProvider.isListening ? Icons.stop : Icons.mic, size: 28),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
