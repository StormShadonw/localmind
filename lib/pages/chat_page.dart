import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:localmind/helpers/theme.dart';
import 'package:localmind/models/message.dart' as local;
import 'package:localmind/providers/data_provider.dart';
import 'package:localmind/widgets/message_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.pageTitle});
  final String pageTitle;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late DataProvider dataProvider;
  TextEditingController _chatController = TextEditingController();
  List<local.Message> chat = [];
  bool aiLoading = false;
  final ScrollController _controller = ScrollController();

  dynamic _activeGemmaChat;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    _initChat();
    super.initState();
  }

  Future<void> _initChat() async {
    if (dataProvider.activeModel != null) {
      _activeGemmaChat = await dataProvider.activeModel!.createChat();
    }
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100)).then(
      (value) => _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  Future<void> sendMessage() async {
    var textMessage = _chatController.value.text.trim();
    if (textMessage.isEmpty) return;

    if (_activeGemmaChat == null && dataProvider.activeModel != null) {
      await _initChat();
    }

    if (_activeGemmaChat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("AI Model is still loading or unavailable."),
        ),
      );
      return;
    }

    setState(() {
      chat.add(local.Message(author: "user", message: textMessage));
      _chatController.clear();
      aiLoading = true;
      chat.add(
        local.Message(author: "aiModel", message: ""),
      ); // Start empty for stream
    });
    _scrollDown();

    try {
      await _activeGemmaChat!.addQueryChunk(
        gemma.Message.text(text: textMessage, isUser: true),
      );

      _activeGemmaChat!.generateChatResponseAsync().listen(
        (gemma.ModelResponse response) {
          if (response is gemma.TextResponse) {
            setState(() {
              if (chat.isNotEmpty && chat.last.author == "aiModel") {
                chat.last.message += response.token;
              }
            });
            _scrollDown();
          }
        },
        onDone: () {
          setState(() {
            aiLoading = false;
          });
        },
        onError: (error) {
          setState(() {
            aiLoading = false;
            if (chat.isNotEmpty && chat.last.author == "aiModel") {
              chat.last.message += "\n\n[Error generating response: $error]";
            }
          });
          _scrollDown();
        },
      );
    } catch (e) {
      setState(() {
        aiLoading = false;
        if (chat.isNotEmpty && chat.last.author == "aiModel") {
          chat.last.message += "\n\n[Exception: $e]";
        }
      });
      _scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              widget.pageTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (chat.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListView.builder(
                        itemCount: chat.length,
                        controller: _controller,
                        itemBuilder:
                            (context, index) =>
                                MessageWidget(message: chat[index]),
                      ),
                    ),
                  ),
                if (aiLoading)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: LoadingAnimationWidget.progressiveDots(
                      color: Theme.of(context).colorScheme.primary,
                      size: size.width * 0.03,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  width: size.width * 0.75,
                  constraints: const BoxConstraints(maxHeight: 55),
                  child: TextFormField(
                    controller: _chatController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.done,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: null,
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.center,
                    expands: true,
                    onFieldSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      suffixIcon: Transform.translate(
                        offset: const Offset(-10, 0),
                        child: IconButton(
                          onPressed: sendMessage,
                          icon: Icon(MdiIcons.sendVariant),
                        ),
                      ),
                      isCollapsed: true,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.secondary,
                      focusColor: Theme.of(context).colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 8,
                      ),
                      hintText: "Type something...",
                      border: inputBorderStyle,
                      enabledBorder: inputBorderStyle,
                      focusedBorder: inputBorderStyle,
                      disabledBorder: inputBorderStyle,
                      errorBorder: inputErrorBorderStyle,
                      focusedErrorBorder: inputErrorBorderStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
