import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:localmind/helpers/converters_helper.dart';
import 'package:localmind/helpers/dis_space_helper.dart';

class DataProvider extends ChangeNotifier {
  double ramAvailable = 0;
  double ramTotal = 0;
  double hdAvailable = 0;

  bool isModelReady = false;
  bool isDownloading = false;
  int downloadProgress = 0;
  String downloadStatusText = "Initialising...";

  InferenceModel? activeModel;

  DataProvider.Init() {
    _loadSystemInfo();
    _initGemmaModel();
  }

  Future<void> _loadSystemInfo() async {
    DiskSpaceHelper.getMemoryInfo().then((value) {
      if (value != null) {
        ramAvailable = ConvertersHelper.bytesToGigabytes(value["free"] as int);
        ramTotal = ConvertersHelper.bytesToGigabytes(value["total"] as int);
        notifyListeners();
      }
    });

    DiskSpaceHelper.getFreeDiskSpace().then((value) {
      if (value != null) {
        hdAvailable = ConvertersHelper.bytesToGigabytes(value.toInt());
        notifyListeners();
      }
    });
  }

  Future<void> _initGemmaModel() async {
    isModelReady = false;
    isDownloading = false;
    notifyListeners();

    try {
      final modelUrl =
          'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm';

      // Initialize flutter_gemma (no token needed for this public repository)
      FlutterGemma.initialize(maxDownloadRetries: 3);

      final isInstalled = await FlutterGemma.isModelInstalled(
        'gemma-4-E4B-it.litertlm',
      );

      if (!isInstalled) {
        isDownloading = true;
        downloadStatusText = "Downloading Gemma 4 E4B...";
        notifyListeners();

        await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
        ).fromNetwork(modelUrl).withProgress((progress) {
          downloadProgress = progress;
          downloadStatusText = "Downloading Gemma 4 E4B ($progress%)";
          notifyListeners();
        }).install();
      }

      downloadStatusText = "Mounting model into memory...";
      isDownloading = false;
      notifyListeners();

      activeModel = await FlutterGemma.getActiveModel(maxTokens: 2048);

      isModelReady = true;
      notifyListeners();
    } catch (e) {
      downloadStatusText = "Error loading model: $e";
      notifyListeners();
      print(e);
    }
  }
}
