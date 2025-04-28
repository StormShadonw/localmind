import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<String?> getFileContent(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();

    var file = File("${directory.path}/$filePath");

    return await file.readAsString();
  }
}
