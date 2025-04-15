import 'package:flutter/material.dart';
import 'package:localmind/helpers/model_downloader_helper.dart';

class ModelDownloadScreen extends StatefulWidget {
  final String modelUrl;
  final String modelName;

  const ModelDownloadScreen({
    super.key,
    required this.modelUrl,
    required this.modelName,
  });

  @override
  State<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends State<ModelDownloadScreen> {
  double _downloadProgress = 0;
  bool _isDownloading = false;
  String? _localModelPath;

  Future<void> _downloadModel() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    final path = await ModelDownloader.downloadModel(
      modelUrl: widget.modelUrl,
      modelName: widget.modelName,
      onProgress: (progress, total, sppedText) {
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
        const SnackBar(content: Text('Modelo descargado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al descargar el modelo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Descargar ${widget.modelName}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDownloading)
              Column(
                children: [
                  CircularProgressIndicator(value: _downloadProgress),
                  Text('${(_downloadProgress * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 20),
                  const Text('Descargando modelo...'),
                ],
              )
            else if (_localModelPath != null)
              const Text('Modelo listo para usar')
            else
              ElevatedButton(
                onPressed: _downloadModel,
                child: const Text('Descargar Modelo'),
              ),
          ],
        ),
      ),
    );
  }
}
