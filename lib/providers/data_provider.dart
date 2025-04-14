import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/material.dart';
import 'package:localmind/helpers/converters_helper.dart';
import 'package:localmind/models/model.dart';
import 'package:system_info3/system_info3.dart';

class DataProvider extends ChangeNotifier {
  String mountedModel = "Not model mounted";
  String donwloadingModel = "Not downloading any model";
  double ramAvailable = 0;
  double vramAvailable = 0;
  double hdAvailable = 0;
  String get status =>
      "${mountedModel} - ${donwloadingModel} - Available RAM: ${ramAvailable.toStringAsFixed(2)} GB - Available VRAM: ${vramAvailable.toStringAsFixed(2)} GB - Available HD: ${hdAvailable.toStringAsFixed(2)} GB";
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
      hardDriveSize: 4,
    ),
  ];

  DataProvider.Init() {
    ramAvailable = ConvertersHelper.bytesToGigabytes(
      SysInfo.getAvailablePhysicalMemory(),
    );
    vramAvailable = ConvertersHelper.bytesToGigabytes(
      SysInfo.getFreeVirtualMemory(),
    );
    // hdAvailable = ConvertersHelper.bytesToGigabytes(
    //   SysInfo.,
    // );
    DiskSpacePlus.getFreeDiskSpace.then((value) {
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
