// lib/crypto/noise_generator.dart

import 'dart:typed_data';
import 'dart:math';
import 'hash_utils.dart';

/// Genera ruido seguro utilizando una expansión de SHA-256 y un módulo específico.
Uint8List generateNoise(int length, int modulus) {
  final random = Random.secure();

  // Genera una semilla aleatoria de 32 bytes para el generador de ruido
  final seed =
      Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));

  // Expande el ruido utilizando SHA-256
  final expandedNoise = generateExpandedSHA256(seed, length);

  // Ajusta los valores dentro del rango del módulo
  for (int i = 0; i < expandedNoise.length; i++) {
    expandedNoise[i] = expandedNoise[i] % modulus;
  }

  return expandedNoise;
}
