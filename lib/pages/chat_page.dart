import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.pageTitle});
  final String pageTitle;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(widget.pageTitle, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
