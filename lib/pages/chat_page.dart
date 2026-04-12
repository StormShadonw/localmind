import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:localmind/models/message.dart' as local;
import 'package:localmind/providers/data_provider.dart';
import 'package:localmind/widgets/message_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.pageTitle});
  final String pageTitle;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late DataProvider dataProvider;
  final TextEditingController _chatController = TextEditingController();
  bool aiLoading = false;
  final ScrollController _scrollController = ScrollController();

  dynamic _activeGemmaChat;

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    _initChat();
    super.initState();
  }

  bool _isInitializing = false;

  Future<void> _initChat() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      if (dataProvider.activeModel != null) {
        _activeGemmaChat = await dataProvider.activeModel!.createChat();
        // Limit history to avoid overloading the local gRPC server during bootstrap
        // Taking the last 10 messages (approx 5 turns)
        final historyLimit = 10;
        final history = dataProvider.chatMessages.length > historyLimit
            ? dataProvider.chatMessages.sublist(dataProvider.chatMessages.length - historyLimit)
            : dataProvider.chatMessages;

        for (var msg in history) {
          if (msg.message.isNotEmpty) {
            await _activeGemmaChat!.addQueryChunk(
              gemma.Message.text(text: msg.message, isUser: msg.author == "user"),
            );
          }
        }
      }
    } finally {
      _isInitializing = false;
    }
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100)).then(
        (value) => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCirc,
        ),
      );
    }
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
      dataProvider.addChatMessage(
        local.LocalMessage(
          author: "user",
          message: textMessage,
          timestamp: DateTime.now(),
        ),
      );
      _chatController.clear();
      aiLoading = true;
      dataProvider.addChatMessage(
        local.LocalMessage(
          author: "aiModel",
          message: "",
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollDown();

    try {
      await _activeGemmaChat!.addQueryChunk(
        gemma.Message.text(text: textMessage, isUser: true),
      );

      _activeGemmaChat!.generateChatResponseAsync().listen(
        (gemma.ModelResponse response) {
          if (response is gemma.TextResponse) {
            dataProvider.updateLastChatMessage(response.token);
            _scrollDown();
          }
        },
        onDone: () {
          setState(() {
            aiLoading = false;
          });
          dataProvider.finishStreamingResponse();
        },
        onError: (error) {
          print("ChatPage: gRPC Error detected: $error");
          setState(() {
            aiLoading = false;
          });

          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains("unavailable") ||
              errorStr.contains("connection refused") ||
              errorStr.contains("socketexception")) {
            
            dataProvider.updateLastChatMessage(
              "\n\n[Conexión perdida con el servicio de IA. Reiniciando...]",
            );
            
            // Trigger automatic restart of the background service
            dataProvider.restartGemmaService().then((_) {
              dataProvider.updateLastChatMessage(
                "\n[Servicio reiniciado. Por favor, reintenta tu mensaje.]",
              );
            });
          } else {
            dataProvider.updateLastChatMessage(
              "\n\n[Error generatindo respuesta: $error]",
            );
          }
          
          dataProvider.finishStreamingResponse();
          _scrollDown();
        },
      );
    } catch (e) {
      setState(() {
        aiLoading = false;
        dataProvider.updateLastChatMessage("\n\n[Exception: $e]");
      });
      dataProvider.finishStreamingResponse();
      _scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.pageTitle, textAlign: TextAlign.start),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              dataProvider.clearChat();
              await _initChat();
            },
            icon: Icon(MdiIcons.deleteOutline, color: Colors.white30),
            tooltip: 'Borrar historial',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer<DataProvider>(
                  builder: (context, provider, child) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 150, // Space for the floating input
                        left: 20,
                        right: 20,
                      ),
                      itemCount: provider.chatMessages.length,
                      itemBuilder:
                          (context, index) => MessageWidget(
                            message: provider.chatMessages[index],
                          ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInputBar(context, size),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, Size size) {
    var colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.background.withOpacity(0),
            colorScheme.background.withOpacity(0.8),
            colorScheme.background,
          ],
          stops: const [0, 0.4, 1],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _chatController,
                          cursorColor: colorScheme.primary,
                          maxLines: 5,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onFieldSubmitted: (_) => sendMessage(),
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: "Escribe algo para comenzar...",
                            hintStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white30),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      if (aiLoading)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        )
                      else
                        IconButton(
                          onPressed: sendMessage,
                          icon: Icon(
                            MdiIcons.sendVariant,
                            color: colorScheme.primary,
                          ),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
