import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shell/shell.dart';

class ModelHelper {
  final Shell shell = Shell();

  Future<Map<String, String>> _getFullEnvironment() async {
    final shellEnv = await Process.run('env', [], runInShell: true);
    final lines = shellEnv.stdout.toString().split('\n');
    final env = <String, String>{};

    for (var line in lines) {
      final parts = line.split('=');
      if (parts.length > 1) {
        env[parts[0]] = parts.sublist(1).join('=');
      }
    }

    return env;
  }

  Future<String> _getPythonPath() async {
    final which = await Process.run('which', ['python3']);
    if (which.exitCode != 0) {
      throw Exception(
        'Python3 no encontrado. Instálalo con: brew install python@3.11',
      );
    }
    return which.stdout.toString().trim();
  }

  Future<String> runModel(String model, String prompt) async {
    try {
      // 1. Obtén rutas absolutas
      final tempDir = await getApplicationDocumentsDirectory();
      final scriptPath = '${tempDir.path}/main.py';
      final pythonPath = await _getPythonPath();

      // 2. Copia el script
      await rootBundle
          .loadString('python_scripts/local_server/main.py')
          .then((content) => File(scriptPath).writeAsString(content));

      // 3. Otorga permisos
      await Process.run('chmod', ['+x', scriptPath]);

      // 4. Ejecuta con entorno completo
      final result = await Process.run(pythonPath, [
        scriptPath,
        model,
        prompt,
        tempDir.path,
      ], environment: await _getFullEnvironment());

      return result.exitCode == 0 ? result.stdout : "Error: ${result.stderr}";
    } catch (e) {
      return "Error crítico: ${e.toString()}";
    }
  }
}
