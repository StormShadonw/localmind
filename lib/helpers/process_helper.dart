import 'dart:io';

class ProcessHelper {
  /// Kills any existing instances of the litertlm-server.jar.
  /// This is essential to prevent multiple instances from consuming RAM/Swap.
  static Future<void> cleanupOldGemmaInstances() async {
    try {
      if (Platform.isMacOS || Platform.isLinux) {
        // Use pkill to terminate any process that has litertlm-server.jar in its command line
        // Using -9 (SIGKILL) to ensure termination of Java processes that might ignore SIGTERM
        final result = await Process.run('pkill', ['-9', '-f', 'litertlm-server.jar']);
        if (result.exitCode == 0) {
          print('ProcessHelper: Successfully cleaned up old Gemma instances.');
        } else if (result.exitCode == 1) {
          // pkill returns 1 if no processes matched, which is perfectly fine here.
          print('ProcessHelper: No existing Gemma instances found to clean up.');
        } else {
          print('ProcessHelper: Error cleaning up instances (exit code ${result.exitCode}): ${result.stderr}');
        }
      } else if (Platform.isWindows) {
        // For Windows, we might need a different command if we ever support it
        // e.g. taskkill /F /IM java.exe /FI "WINDOWTITLE eq ..." or similar
        // But for now, the user is on Mac.
      }
    } catch (e) {
      print('ProcessHelper: Exception during cleanup: $e');
    }
  }
}
