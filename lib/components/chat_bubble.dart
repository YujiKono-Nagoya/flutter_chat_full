import 'package:flutter/material.dart';
import 'package:flutter_chat_full/model/message.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool conditions;

  const ChatBubble(
      {super.key, required this.message, required this.conditions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: conditions ? Colors.orange : Colors.grey[400],
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
