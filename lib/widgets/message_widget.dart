import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:localmind/models/message.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var colorScheme = Theme.of(context).colorScheme;
    var isUserMessage = message.author == "user";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) _buildAvatar(context),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: isUserMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isUserMessage
                            ? colorScheme.primary.withOpacity(0.15)
                            : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUserMessage ? 16 : 4),
                      bottomRight: Radius.circular(isUserMessage ? 4 : 16),
                    ),
                    border:
                        isUserMessage
                            ? Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                            )
                            : null,
                  ),
                  child: MarkdownBody(
                    data: message.message.trim(),
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: Theme.of(context).textTheme.bodyLarge,
                      code: TextStyle(
                        backgroundColor: Colors.black26,
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: colorScheme.primary,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isUserMessage) _buildAvatar(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    var isUserMessage = message.author == "user";

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUserMessage ? colorScheme.secondary : colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isUserMessage ? colorScheme.secondary : colorScheme.primary)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          isUserMessage ? MdiIcons.account : MdiIcons.robot,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
