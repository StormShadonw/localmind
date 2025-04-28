import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:localmind/helpers/errors.dart';
import 'package:localmind/helpers/file_helpers.dart';
import 'package:localmind/helpers/model_helper.dart';
import 'package:localmind/helpers/shared_preferences_helper.dart';
import 'package:localmind/helpers/theme.dart';
import 'package:localmind/models/message.dart';
import 'package:localmind/providers/data_provider.dart';
import 'package:localmind/widgets/message_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.pageTitle});
  final String pageTitle;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? modelSelected = null;
  List<List<String>> dropdownItems = [];
  late DataProvider dataProvider;
  bool isLodaing = false;
  TextEditingController _chatController = TextEditingController();
  FocusNode? textFieldNode;
  List<Message> chat = [];
  bool aiLoading = false;
  final ScrollController _controller = ScrollController();

  void refreshChatsData(String content) {
    var sections = content.split("--------------------");
    for (String section in sections) {
      if (section.split("aiModel: ").length > 1) {
        var aiModelMessage = section.split("aiModel: ")[1];
        var userMessage = section
            .split("aiModel: ")[0]
            .replaceAll("user: ", "");
        chat.add(Message(author: "user", message: userMessage));
        chat.add(Message(author: "aiModel", message: aiModelMessage));
      }
    }
    setState(() {});
  }

  Future<void> getChatData(String model) async {
    chat.clear();
    var validNameFile = model.replaceAll("/", "_");

    var fileContent = await FileHelper.getFileContent(
      "chats/$validNameFile.txt",
    );
    if (fileContent != null) {
      refreshChatsData(fileContent);
    }
    _scrollDown();
  }

  Future<void> getInitData() async {
    setState(() {
      isLodaing = true;
    });

    var model = await SharedPreferencesHelper.getValue("aiModelSelected");
    if (model.isNotEmpty) {
      modelSelected = model;
      getChatData(modelSelected ?? "");
    }

    setState(() {
      isLodaing = false;
    });
  }

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    getInitData();
    textFieldNode = FocusNode(
      onKeyEvent: (node, event) {
        final enterPressedWithoutShift =
            event is KeyDownEvent &&
            event.physicalKey == PhysicalKeyboardKey.enter &&
            !HardwareKeyboard.instance.physicalKeysPressed.any(
              (key) => <PhysicalKeyboardKey>{
                PhysicalKeyboardKey.shiftLeft,
                PhysicalKeyboardKey.shiftRight,
              }.contains(key),
            );

        if (enterPressedWithoutShift) {
          // Submit stuff
          return KeyEventResult.handled;
        } else if (event is KeyRepeatEvent) {
          // Disable holding enter
          return KeyEventResult.handled;
        } else {
          return KeyEventResult.ignored;
        }
      },
    );

    super.initState();
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
    try {
      var message = _chatController.value.text;
      if (modelSelected == null || modelSelected!.isEmpty) {
        showError(context, "You need first to select a model");
        return;
      }
      if (message.isEmpty) {
        showError(context, "You need first to type a text");
        return;
      }
      setState(() {
        aiLoading = true;
      });
      var result = await ModelHelper().runModel(modelSelected ?? "", message);
      // await Future.delayed(const Duration(seconds: 15));
      await getChatData(modelSelected ?? "");
      setState(() {
        aiLoading = false;
      });
      _scrollDown();
      print("Model Result: $result");
      _chatController.clear();
    } catch (error) {
      setState(() {
        aiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    GlobalKey dropdownKey = GlobalKey();
    return Container(
      child: Column(
        children: [
          Text(widget.pageTitle, style: Theme.of(context).textTheme.titleLarge),
          Consumer<DataProvider>(
            builder: (context, value, child) {
              var downloadedModels = value.models;
              dropdownItems.clear();
              dropdownItems.addAll(
                List.generate(
                  downloadedModels.length,
                  (index) => [
                    downloadedModels[index].name,
                    downloadedModels[index].description,
                  ],
                ),
              );

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                // color: Colors.red,
                // padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "model:",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: size.width * 0.75,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1.0,
                              style: BorderStyle.solid,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: DropdownButton2(
                            iconStyleData: IconStyleData(
                              iconEnabledColor: Colors.white,
                            ),
                            selectedItemBuilder:
                                (context) => List.generate(
                                  downloadedModels.length,
                                  (index) => DropdownMenuItem(
                                    value: downloadedModels[index].name,

                                    child: Container(
                                      // color:
                                      //     Theme.of(context).colorScheme.primary,
                                      child: Text(
                                        downloadedModels[index].description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,

                              decoration: BoxDecoration(
                                // color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            key: dropdownKey,

                            menuItemStyleData: MenuItemStyleData(height: 15),
                            underline: const SizedBox(),
                            isExpanded: true,

                            isDense: true,
                            hint: Text(
                              'Select a model',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(color: Colors.white),
                            value: modelSelected,
                            items:
                                dropdownItems
                                    .map<DropdownMenuItem<String>>(
                                      (List<String> item) =>
                                          DropdownMenuItem<String>(
                                            value: item[0],

                                            child: Text(
                                              item[1],

                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall!.copyWith(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                    )
                                    .toList(),
                            onChanged: (String? value) {
                              SharedPreferencesHelper.setValue(
                                "aiModelSelected",
                                value ?? "",
                              );
                              setState(() => modelSelected = value!);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
                    child: LoadingAnimationWidget.progressiveDots(
                      color: Theme.of(context).colorScheme.primary,
                      size: size.width * 0.03,
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  width: size.width * 0.75,
                  constraints: BoxConstraints(maxHeight: 55),
                  child: TextFormField(
                    controller: _chatController,
                    // focusNode: textFieldNode,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.done,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: null,
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.center,
                    expands: true,
                    onEditingComplete: sendMessage,

                    decoration: InputDecoration(
                      suffixIcon: Transform.translate(
                        offset: Offset(-10, 0),
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
