// noise_generator.dart
//
// Generates a sequence of deterministic pseudo-random bytes from a seed
// using SHAKE128, and then reduces each byte modulo [modulus].
//
// This is not the way Kyber generates its secret noise for keys or ciphertext
// (for that, polygetnoise is used), but it can be useful as a generic
// function to obtain deterministic noise from a seed.

import 'dart:typed_data';
import 'shake.dart';

/// Generates [length] bytes of deterministic noise from [seed] using SHAKE128.
/// Then, each byte is reduced mod [modulus].
Uint8List generateNoise(Uint8List seed, int length, int modulus) {
  // Expand the seed with SHAKE128 to obtain length bytes
  Uint8List expanded = shake128(seed, length);

  // Adjust values to be within the range [0, modulus)
  for (int i = 0; i < expanded.length; i++) {
    expanded[i] = expanded[i] % modulus;
  }

  return expanded;
}
