import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:localmind/providers/data_provider.dart';
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

    super.initState();
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
                            selectedItemBuilder:
                                (context) => List.generate(
                                  downloadedModels.length,
                                  (index) => DropdownMenuItem(
                                    value: downloadedModels[index].name,
                                    child: Text(
                                      downloadedModels[index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
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
        ],
      ),
    );
  }
}
