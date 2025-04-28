import 'package:flutter/material.dart';
import 'package:localmind/models/message.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    var colorScheme = Theme.of(context).colorScheme;
    var isUserMessage = message.author == "user";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // width: size.width * 0.55,
        constraints: BoxConstraints(
          maxWidth: isUserMessage ? size.width * 0.55 : size.width,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: !isUserMessage ? colorScheme.primary : colorScheme.secondary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          message.message.trim(),
          style: textTheme.bodySmall!.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
