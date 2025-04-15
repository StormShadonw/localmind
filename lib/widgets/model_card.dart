import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:localmind/helpers/converters_helper.dart';
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
  late Model model;
  double _downloadProgress = 0;
  bool _isDownloading = false;
  String? _localModelPath;
  late DataProvider dataProvider;
  CancelToken? cancelToken;
  bool showDonwloadError = true;

  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });
    setState(() {
      showDonwloadError = true;
    });
    final path = await ModelDownloader.downloadModel(
      modelUrl: widget.model.url,
      modelName: widget.model.name,
      onProgress: (progress, total, speedText) {
        var progressPrc = (progress * 100).toStringAsFixed(2);
        dataProvider.setDownloadingModel(
          "Downloadng model progress: $progressPrc% at $speedText",
        );
        if (model.hardDriveSize == null) {
          setState(() {
            model.hardDriveSize = ConvertersHelper.bytesToGigabytes(
              total.toInt(),
            );
          });
        }
        setState(() {
          _downloadProgress = progress;
        });
      },
      onCancelToken: (p0) => cancelToken = p0,
    );

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
      setState(() {
        model.downloaded = true;
        _isDownloading = false;
      });
      dataProvider.setModelDownloaded(model.name, path);
    } else {
      if (showDonwloadError) {
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
  }

  @override
  void initState() {
    dataProvider = Provider.of<DataProvider>(context, listen: false);
    model = widget.model;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return ListTile(
      key: Key(model.name),
      title: Text(model.description, style: textTheme.bodyMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("RAM: ${model.ramRequirements}GB", style: textTheme.bodySmall),
          Text("VRAM: ${model.vramRequirements}GB", style: textTheme.bodySmall),
          if (model.hardDriveSize != null)
            Text(
              "HD: ${model.hardDriveSize!.toStringAsFixed(2)}GB",
              style: textTheme.bodySmall,
            ),
        ],
      ),
      trailing:
          _isDownloading
              ? Container(
                width: 55,
                height: 55,
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        value: _downloadProgress,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary,
                        ),
                        backgroundColor: Colors.blueGrey,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: () {
                          if (cancelToken != null) {
                            cancelToken!.cancel();
                            setState(() {
                              _isDownloading = false;
                              showDonwloadError = false;
                            });
                            dataProvider.setDownloadingModel(
                              "Not downloading any model",
                            );
                          }
                        },
                        icon: Icon(MdiIcons.downloadOff),
                        iconSize: 20,
                      ),
                    ),
                  ],
                ),
              )
              : Container(
                width: 55,
                height: 55,
                padding: const EdgeInsets.all(6.0),
                child: IconButton(
                  onPressed: model.downloaded ? null : _downloadModel,
                  icon: Icon(
                    model.downloaded ? MdiIcons.check : MdiIcons.download,
                  ),
                ),
              ),
    );
  }
}
