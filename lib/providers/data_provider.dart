import 'package:flutter/material.dart';
import 'package:localmind/helpers/converters_helper.dart';
import 'package:localmind/helpers/dis_space_helper.dart';
import 'package:localmind/helpers/shared_preferences_helper.dart';
import 'package:localmind/models/model.dart';
import 'package:system_info3/system_info3.dart';

class DataProvider extends ChangeNotifier {
  String mountedModel = "Not model mounted";
  String donwloadingModel = "Not downloading any model";
  double ramAvailable = 0;
  double ramTotal = 0;
  double vramAvailable = 0;
  double hdAvailable = 0;
  bool loadingModels = false;
  String get status =>
      "${mountedModel} - ${donwloadingModel} - Available RAM: ${ramAvailable.toStringAsFixed(2)} GB / ${ramTotal.toStringAsFixed(2)} GB - Available HD: ${hdAvailable.toStringAsFixed(2)} GB";
  List<Model> models = [
    Model(
      name: "mlx-community/DeepSeek-R1-Distill-Qwen-7B-4bit",
      url:
          "https://www.kaggle.com/api/v1/models/deepseek-ai/deepseek-r1/transformers/deepseek-r1-distill-qwen-7b/2/download",
      description: "Uso General",
      author: "DeepSeek",
      advantages: "Generacion de texto",
      ramRequirements: 4,
      vramRequirements: 4,
      hardDriveSize: null,
      downloaded: false,
      downloadedPath: null,
    ),
  ];

  Future<void> setLoadingModels(bool value) async {
    loadingModels = value;
    notifyListeners();
  }

  Future<void> setModelDownloaded(String modelName, String path) async {
    var model = models.firstWhere((element) => element.name == modelName);
    model.downloaded = true;
    model.downloadedPath = path;
    await SharedPreferencesHelper.setValue(modelName, "$modelName:::$path");
    notifyListeners();
  }

  Future<void> loadModelsState() async {
    try {
      setLoadingModels(true);
      print("validating models");
      for (var model in models) {
        var result = await SharedPreferencesHelper.getValue(model.name);
        if (result != null) {
          model.downloadedPath = result.split(":::")[1];
          model.downloaded = true;
        }
      }
      setLoadingModels(false);
    } catch (e) {
      setLoadingModels(false);
      print("Error loadModelState: $e");
    }
  }

  DataProvider.Init() {
    // hdAvailable = ConvertersHelper.bytesToGigabytes(
    //   SysInfo.,
    // );

    loadModelsState();
    DiskSpaceHelper.getMemoryInfo().then((value) {
      print("Memory info: $value");
      ramAvailable =
          value == null
              ? 0
              : ConvertersHelper.bytesToGigabytes(
                value == null
                    ? 0
                    // : (value["total"] as int) - (value["used"] as int),
                    : (value["free"] as int),
              );
      ramTotal =
          value == null
              ? 0
              : ConvertersHelper.bytesToGigabytes(
                value == null
                    ? 0
                    // : (value["total"] as int) - (value["used"] as int),
                    : (value["total"] as int),
              );
      notifyListeners();
    });

    DiskSpaceHelper.getFreeDiskSpace().then((value) {
      hdAvailable =
          value == null
              ? 0
              : ConvertersHelper.bytesToGigabytes(
                value == null ? 0 : value.toInt(),
              );
      notifyListeners();
    });
    notifyListeners();
  }

  void setMountedModel(String modelName) {
    mountedModel = modelName;
    notifyListeners();
  }

  void setDownloadingModel(String value) {
    donwloadingModel = value;
    notifyListeners();
  }

  void setRamAvailable(String ramAvailable) {
    ramAvailable = ramAvailable;
    notifyListeners();
  }

  void setVramAvailable(String vramAvailable) {
    vramAvailable = vramAvailable;
    notifyListeners();
  }

  void setHdAvailable(String hdAvailable) {
    hdAvailable = hdAvailable;
    notifyListeners();
  }
}
