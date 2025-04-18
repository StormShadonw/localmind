import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localmind/helpers/errors.dart';
import 'package:localmind/helpers/theme.dart';
import 'package:localmind/providers/data_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.pageTitle});
  final String pageTitle;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String? modelSelected = null;
  List<String> dropdownItems = [];
  late DataProvider dataProvider;
  bool isLodaing = false;
  TextEditingController _chatController = TextEditingController();
  FocusNode? textFieldNode;

  Future<void> getInitData() async {
    setState(() {
      isLodaing = true;
    });

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

  Future<void> sendMessage() async {
    var message = _chatController.value.text;
    if (modelSelected == null || modelSelected!.isEmpty) {
      showError(context, "You need first to select a model");
      return;
    }
    if (message.isEmpty) {
      showError(context, "You need first to type a text");
      return;
    }
    print("Message: $message");
    _chatController.clear();
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
                  (index) => downloadedModels[index].name,
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
                                        downloadedModels[index].name,
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
                                      (String item) => DropdownMenuItem<String>(
                                        value: item,

                                        child: Text(
                                          item,

                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(color: Colors.black87),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (String? value) =>
                                    setState(() => modelSelected = value!),
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
                Container(
                  decoration: BoxDecoration(
                    // color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  width: size.width * 0.75,
                  constraints: BoxConstraints(maxHeight: 115),
                  child: TextFormField(
                    controller: _chatController,
                    focusNode: textFieldNode,

                    textInputAction: TextInputAction.newline,
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
