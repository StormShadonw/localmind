import 'dart:io';

class ProcessHelper {
  /// Kills any existing instances of the litertlm-server.jar.
  /// This is essential to prevent multiple instances from consuming RAM/Swap.
  static Future<void> cleanupOldGemmaInstances() async {
    try {
      if (Platform.isMacOS || Platform.isLinux) {
        print('ProcessHelper: Looking for existing Gemma instances...');
        // Use pkill to terminate any process that has litertlm-server.jar in its command line
        // Using -9 (SIGKILL) to ensure termination of Java processes that might ignore SIGTERM
        final result = await Process.run('pkill', ['-9', '-f', 'litertlm-server.jar']);
        
        if (result.exitCode == 0) {
          print('ProcessHelper: Found and killed existing Gemma instances.');
          // Give the OS a moment to fully release resources/ports
          await Future.delayed(const Duration(milliseconds: 500));
        } else if (result.exitCode == 1) {
          print('ProcessHelper: No existing Gemma instances found.');
        } else {
          print('ProcessHelper: pkill returned exit code ${result.exitCode}: ${result.stderr}');
        }
      }
    } catch (e) {
      print('ProcessHelper: Exception during cleanup: $e');
    }
  }
}
