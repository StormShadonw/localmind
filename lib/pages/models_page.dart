import 'package:flutter/material.dart';
import 'package:localmind/providers/data_provider.dart';
import 'package:localmind/widgets/model_card.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key, required this.pageTitle});
  final String pageTitle;

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var textTheme = Theme.of(context).textTheme;
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.pageTitle, style: textTheme.titleLarge),
          Consumer<DataProvider>(
            builder: (context, value, child) {
              return Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  child: ListView.builder(
                    itemCount: value.models.length,

                    itemBuilder: (context, index) {
                      var model = value.models[index];
                      return ModelCard(model: model);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
