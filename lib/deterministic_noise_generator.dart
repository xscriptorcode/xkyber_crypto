// lib/crypto/deterministic_noise_generator.dart

import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/api.dart';

/// Genera ruido determinista seguro utilizando AES en modo CTR.
class DeterministicNoiseGenerator {
  final Uint8List seed;
  final int length;

  DeterministicNoiseGenerator(this.seed, this.length);

  Uint8List generateNoise() {
    final key = KeyParameter(seed);
    final iv = Uint8List(16); // Vector de inicialización en cero
    final ctrCipher = StreamCipher('AES/CTR')
      ..init(true, ParametersWithIV(key, iv));

    final noise = Uint8List(length);
    ctrCipher.process(noise);

    return noise;
  }
}
