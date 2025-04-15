import 'package:flutter/material.dart';
import 'package:localmind/helpers/converters_helper.dart';
import 'package:localmind/helpers/dis_space_helper.dart';
import 'package:localmind/models/model.dart';
import 'package:system_info3/system_info3.dart';

class DataProvider extends ChangeNotifier {
  String mountedModel = "Not model mounted";
  String donwloadingModel = "Not downloading any model";
  double ramAvailable = 0;
  double ramTotal = 0;
  double vramAvailable = 0;
  double hdAvailable = 0;
  String get status =>
      "${mountedModel} - ${donwloadingModel} - Available RAM: ${ramAvailable.toStringAsFixed(2)} GB / ${ramTotal.toStringAsFixed(2)} GB - Available HD: ${hdAvailable.toStringAsFixed(2)} GB";
  List<Model> models = [
    Model(
      name: "deepseek-r1-distill-qwen-7b",
      url:
          "https://www.kaggle.com/api/v1/models/deepseek-ai/deepseek-r1/transformers/deepseek-r1-distill-qwen-7b/2/download",
      description: "Uso General(deepseek-r1-distill-qwen-7b)",
      author: "DeepSeek",
      advantages: "Generacion de texto",
      ramRequirements: 4,
      vramRequirements: 4,
      hardDriveSize: null,
      downloaded: false,
      downloadedPath: null,
    ),
  ];

  DataProvider.Init() {
    // hdAvailable = ConvertersHelper.bytesToGigabytes(
    //   SysInfo.,
    // );

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
