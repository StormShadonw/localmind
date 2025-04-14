import 'package:flutter/material.dart';
import 'package:localmind/helpers/model_downloader_helper.dart';
import 'package:localmind/models/model.dart';
import 'package:localmind/providers/data_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ModelCard extends StatefulWidget {
  const ModelCard({super.key, required this.model});
  final Model model;

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  double _downloadProgress = 0;
  bool _isDownloading = false;
  String? _localModelPath;
  late DataProvider dataProvider;

  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    final path = await ModelDownloader.downloadModel(
      modelUrl: widget.model.url,
      modelName: widget.model.name,
      onProgress: (progress, total) {
        var progressPrc = (progress * 100).toStringAsFixed(2);
        dataProvider.setDownloadingModel(
          "Downloadng model progress: $progressPrc%",
        );
        setState(() {
          _downloadProgress = progress;
        });
      },
    );

    setState(() {
      _isDownloading = false;
      _localModelPath = path;
    });

    if (path != null) {
      // Modelo descargado correctamente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Modelo descargado correctamente',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.black),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al descargar el modelo',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.black),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var model = widget.model;
    var textTheme = Theme.of(context).textTheme;
    return ListTile(
      key: Key(model.name),
      title: Text(model.description, style: textTheme.bodyMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("RAM: ${model.ramRequirements}GB", style: textTheme.bodySmall),
          Text("VRAM: ${model.vramRequirements}GB", style: textTheme.bodySmall),
          Text("HD: ${model.hardDriveSize}GB", style: textTheme.bodySmall),
        ],
      ),
      trailing:
          _isDownloading
              ? CircularProgressIndicator(
                value: _downloadProgress,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              )
              : IconButton(
                onPressed: _downloadModel,
                icon: Icon(MdiIcons.download),
              ),
    );
  }
}
