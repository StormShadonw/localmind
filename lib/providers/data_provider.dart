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
  double downloadProgressDouble = 0.0;
  bool hasError = false;
  String downloadStatusText = "Initialising...";
  String downloadSpeed = "";
  String totalSizeText = "";
  String downloadedSizeText = "";

  InferenceModel? activeModel;
  int _lastBytes = 0;
  int _lastTime = 0; // ms

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
    hasError = false;
    _lastBytes = 0;
    _lastTime = 0;
    downloadProgress = 0;
    downloadProgressDouble = 0.0;
    downloadSpeed = "";
    downloadedSizeText = "";
    totalSizeText = "";
    notifyListeners();

    try {
      final modelUrl =
          'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/resolve/main/gemma-4-E4B-it.litertlm';

      // Initialize flutter_gemma (handled in main)

      final isInstalled = await FlutterGemma.isModelInstalled(
        'gemma-4-E4B-it.litertlm',
      );

      if (!isInstalled) {
        isDownloading = true;
        downloadStatusText = "Downloading Local AI Model";
        notifyListeners();

        final totalBytes = 3654467584; // 3.4 GB as detected from the URL
        final stopwatch = Stopwatch()..start();

        await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
        ).fromNetwork(modelUrl).withProgress((progress) {
          int currentBytes = 0;
          double percentDouble = 0;
          int? totalBytesFromObject;

          if (progress is int) {
            percentDouble = progress / 100.0;
            currentBytes = (totalBytes * percentDouble).toInt();
          } else if (progress is double) {
            percentDouble =
                progress > 1.0 ? progress / 100.0 : progress.toDouble();
            currentBytes = (totalBytes * percentDouble).toInt();
          } else {
            // Try to extract downloaded bytes and percentage from object dynamically
            try {
              final dp = progress as dynamic;
              // Try common property names for bytes
              currentBytes =
                  dp.downloaded?.toInt() ??
                  dp.receivedBytes?.toInt() ??
                  dp.bytesDownloaded?.toInt() ??
                  0;

              // Try common property names for total
              totalBytesFromObject =
                  dp.totalSize?.toInt() ?? dp.totalBytes?.toInt();

              // Try common property names for percentage
              final p = dp.percentage ?? dp.progress;
              if (p != null) {
                percentDouble =
                    p is double ? (p > 1.0 ? p / 100.0 : p) : p / 100.0;
              }

              // Fallback for currentBytes if still 0 but we have percentage
              if (currentBytes == 0 && percentDouble > 0) {
                currentBytes =
                    ((totalBytesFromObject ?? totalBytes) * percentDouble)
                        .toInt();
              }
            } catch (e) {
              // Final fallback to numeric logic if it's actually numeric but didn't match types above
              if (progress is num) {
                percentDouble =
                    progress > 1.0 ? progress / 100.0 : progress.toDouble();
                currentBytes = (totalBytes * percentDouble).toInt();
              }
            }
          }

          final displayTotal = totalBytesFromObject ?? totalBytes;

          // Always update these for immediate feedback
          downloadProgress = (percentDouble * 100).toInt();
          downloadProgressDouble = percentDouble * 100;
          downloadedSizeText =
              "${(currentBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
          totalSizeText =
              "${(displayTotal / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";

          final now = stopwatch.elapsedMilliseconds;
          final timeDiff = now - _lastTime;

          if (timeDiff >= 500) {
            final byteDiff = currentBytes - _lastBytes;
            if (byteDiff > 0) {
              final speedMBs = (byteDiff / (1024 * 1024)) / (timeDiff / 1000.0);
              downloadSpeed = "${speedMBs.toStringAsFixed(2)} MB/s";

              // Only update baseline when we actually had a chunk to measure speed
              _lastBytes = currentBytes;
              _lastTime = now;
            } else if (timeDiff >= 2000) {
              // If 2 seconds passed without bytes, speed is 0
              downloadSpeed = "0.00 MB/s";
              _lastTime = now;
              _lastBytes = currentBytes;
            }
          } else if (_lastTime == 0) {
            _lastBytes = currentBytes;
            _lastTime = now;
          }
          notifyListeners();
        }).install();
        stopwatch.stop();
      }

      downloadStatusText = "Mounting model into memory...";
      isDownloading = false;
      notifyListeners();

      activeModel = await FlutterGemma.getActiveModel(maxTokens: 2048);

      isModelReady = true;
      notifyListeners();
    } catch (e) {
      hasError = true;
      downloadStatusText = "Error loading model: $e";
      notifyListeners();
      print(e);
    }
  }

  void retryInitialization() {
    _initGemmaModel();
  }
}
