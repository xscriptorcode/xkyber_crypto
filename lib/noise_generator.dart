// noise_generator.dart
//
// Genera una secuencia de bytes pseudoaleatorios determinísticos a partir de una semilla
// usando SHAKE128, y luego reduce cada byte modulo [modulus].
//
// Esta no es la forma en que Kyber genera su ruido secreto para claves o ciphertext
// (para eso se usa poly_getnoise), pero puede ser útil como función genérica
// para obtener ruido determinístico a partir de una semilla.

import 'dart:typed_data';
import 'shake.dart';

/// Genera [length] bytes de ruido determinístico a partir de [seed] usando SHAKE128.
/// Luego, cada byte se reduce mod [modulus].
Uint8List generateNoise(Uint8List seed, int length, int modulus) {
  // Expandir la semilla con SHAKE128 para obtener length bytes
  Uint8List expanded = shake128(seed, length);

  // Ajustar valores dentro del rango [0, modulus)
  for (int i = 0; i < expanded.length; i++) {
    expanded[i] = expanded[i] % modulus;
  }

  return expanded;
}
