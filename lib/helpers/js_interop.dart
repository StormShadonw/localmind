import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS()
@staticInterop
class MyAppInterop {
  external factory MyAppInterop();
}

extension MyAppInteropExtension on MyAppInterop {
  // Declaración de la función asíncrona
  external JSPromise aiAvailability();

  // Versión amigable para Dart
  Future<String> aiAvailabilityJS() async {
    try {
      final promise = aiAvailability();
      final result = await promise.toDart;
      return (result).dartify() as String;
    } catch (e) {
      print('Error calling aiAvailability: $e');
      rethrow;
    }
  }
}

// Acceso al objeto global
@JS()
external MyAppInterop get myAppInterop;

// Helper para conversión de tipos
extension on JSObject {
  dynamic get dartify => dartify(this);
}
