// screens/chat_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_session_model.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              chatProvider.createNewChatSession();
              Navigator.pop(context); // Return to chat screen
            },
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: StreamBuilder<List<ChatSession>>(
        stream: chatProvider.chatSessionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading chat history',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No chat history yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start a new conversation to see it here',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      chatProvider.createNewChatSession();
                      Navigator.pop(context);
                    },
                    child: Text('Start New Chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final isCurrentSession =
                  session.sessionId == chatProvider.currentSessionId;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                color: isCurrentSession
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1)
                    : null,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chat, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    session.title,
                    style: TextStyle(
                      fontWeight: isCurrentSession
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${session.messageCount} messages'),
                      Text(session.formattedLastActivity),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(
                          context,
                          chatProvider,
                          session.sessionId,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    chatProvider.switchChatSession(session.sessionId);
                    Navigator.pop(context); // Return to chat screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ChatProvider chatProvider,
    String sessionId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Chat?'),
          content: Text(
            'This action cannot be undone. All messages in this chat will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                chatProvider.deleteChatSession(sessionId);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
