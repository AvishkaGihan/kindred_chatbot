import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kindred Chatbot',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const InitialWidget(),
    );
  }
}

class InitialWidget extends StatelessWidget {
  const InitialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kindred Chatbot')),
      body: const Center(child: Text('Welcome — tap the button to start')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to your main screen or start initialization
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Start action (replace as needed)')),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
