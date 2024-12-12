// randombytes.dart
//
// Genera bytes aleatorios criptográficamente seguros usando Random.secure() de Dart.
// Esta función se basa en el soporte nativo de la plataforma para proveer entropía.
// Es importante confirmar que la plataforma donde corre Dart provea suficiente entropía.
// Para mayor robustez, en entornos críticos, podría ser necesario recurrir a mecanismos nativos.
//
// Por ahora, este método es suficiente para la implementación de Kyber en entornos soportados por Dart.

import 'dart:math';
import 'dart:typed_data';

/// Genera [length] bytes aleatorios con calidad criptográfica.
/// Usa `Random.secure()` para obtener entropía del sistema.
Uint8List randombytes(int length) {
  final rnd = Random.secure();
  return Uint8List.fromList(List<int>.generate(length, (_) => rnd.nextInt(256)));
}
