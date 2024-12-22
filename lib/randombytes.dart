// randombytes.dart

import 'dart:math';
import 'dart:typed_data';

/// Genera bytes aleatorios criptográficamente seguros usando Random.secure() de Dart.
/// Esta función se basa en el soporte nativo de la plataforma para proveer entropía.
/// Es importante confirmar que la plataforma donde corre Dart provea suficiente entropía.
/// Para mayor robustez, en entornos críticos, podría ser necesario recurrir a mecanismos nativos.
///
/// Por ahora, este método es suficiente para la implementación de Kyber en entornos soportados por Dart.
/// Generates [length] cryptographically secure random bytes.
/// Uses `Random.secure()` to obtain system entropy.
Uint8List randombytes(int length) {
  final Random rnd = Random.secure();
  return Uint8List.fromList(
      List<int>.generate(length, (_) => rnd.nextInt(256)));
}
