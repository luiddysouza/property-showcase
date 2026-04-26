import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String conversationId;

  const ChatPage({
    super.key,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Chat: $conversationId')),
    );
  }
}
