import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ModelDownloader {
  static Future<String> get _modelsDir async {
    final directory = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${directory.path}/ai_models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }

  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS no necesita permiso explícito para DocumentsDirectory
  }

  static Future<String?> downloadModel({
    required String modelUrl,
    required String modelName,
    Function(double, double)? onProgress,
    Function(CancelToken)? onCancelToken,
  }) async {
    try {
      if (!await _requestPermissions()) {
        throw Exception('Permisos denegados');
      }

      final modelsPath = await _modelsDir;
      final filePath = '$modelsPath/$modelName';
      print("Model path: $filePath");

      // Usando dio para descarga con progreso
      final dio = Dio();
      final response = await dio.download(
        modelUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total, total.toDouble());
          }
        },
        cancelToken: onCancelToken!(CancelToken()),
      );

      if (response.statusCode == 200) {
        return filePath;
      }
      return null;
    } catch (e) {
      print('Error descargando modelo: $e');
      return null;
    }
  }

  // Alternativa con cache
  static Future<String?> downloadWithCache(String modelUrl) async {
    final file = await DefaultCacheManager().getSingleFile(modelUrl);
    return file.path;
  }

  static Future<bool> modelExists(String modelName) async {
    final modelsPath = await _modelsDir;
    return File('$modelsPath/$modelName').exists();
  }

  static Future<String?> getModelPath(String modelName) async {
    if (await modelExists(modelName)) {
      final modelsPath = await _modelsDir;
      return '$modelsPath/$modelName';
    }
    return null;
  }
}
