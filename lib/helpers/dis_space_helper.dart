import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';

class DiskSpaceHelper {
  static const MethodChannel _channel = MethodChannel('disk_space');

  /// Obtiene el espacio libre en disco en bytes
  static Future<int> getFreeDiskSpace() async {
    try {
      final result = await _channel.invokeMethod('getFreeDiskSpace');
      return result as int;
    } on PlatformException catch (e) {
      print("Error al obtener espacio libre: ${e.message}");
      return -1;
    }
  }

  /// Obtiene el espacio total en disco en bytes
  static Future<int> getTotalDiskSpace() async {
    try {
      final result = await _channel.invokeMethod('getTotalDiskSpace');
      return result as int;
    } on PlatformException catch (e) {
      print("Error al obtener espacio total: ${e.message}");
      return -1;
    }
  }

  /// Obtiene el espacio usado en disco en bytes
  static Future<int> getUsedDiskSpace() async {
    try {
      final total = await getTotalDiskSpace();
      final free = await getFreeDiskSpace();
      return total - free;
    } on PlatformException catch (e) {
      print("Error al calcular espacio usado: ${e.message}");
      return -1;
    }
  }

  /// Formatea bytes a una cadena legible (GB, MB, etc.)
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
