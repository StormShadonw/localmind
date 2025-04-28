import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shell/shell.dart';

class ModelHelper {
  final Shell shell = Shell();

  Future<String> runModel(String model, String prompt) async {
    try {
      final scriptContent = await rootBundle.loadString(
        'python_scripts/local_server/main.py',
      );
      print("scriptContent: $scriptContent");
      final tempDir = await getApplicationDocumentsDirectory();
      final scriptPath = '${tempDir.path}/main.py';
      await File(scriptPath).writeAsString(scriptContent);
      // await shell.run('chmod +x $scriptPath');
      var command = '''
python3 $scriptPath "mlx-community/DeepSeek-R1-Distill-Qwen-7B-4bit" "$prompt" "${tempDir.path}"                 
      ''';
      print("command: $command");
      var result = await shell.run(command);

      print("Result: ${result.exitCode}");
      return result.stdout;
    } catch (e) {
      return "Error: $e";
    }
  }
}
