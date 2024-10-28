// lib/crypto/kyber_keypair.dart

import 'dart:typed_data';
import 'polynomial.dart';
import 'package:pointycastle/pointycastle.dart';
import 'dart:math';

class KyberKeyPair {
  final Polynomial publicKey;
  final Polynomial privateKey;

  KyberKeyPair._(this.publicKey, this.privateKey);

  KyberKeyPair.fromPolynomials(this.publicKey, this.privateKey);

  factory KyberKeyPair.generate({Polynomial? publicKey, Polynomial? privateKey}) {
    if (publicKey != null && privateKey != null) {
      return KyberKeyPair._(publicKey, privateKey);
    }

    final secureRandom = SecureRandom('Fortuna')
      ..seed(KeyParameter(_generateSeed(32)));

    final List<int> noise = [];
    int attempts = 0;
    while (noise.length < 256) {
      final bytes = secureRandom.nextBytes(2);
      int value = (bytes[0] << 8) | bytes[1]; // 0 to 65535
      value = value % 3329; // 0 to 3328
      if (value == 0) continue; // Rechaza ceros
      noise.add(value); // 1 a 3328
      attempts++;
      if (attempts > 100000) throw Exception('No se pudo generar ruido sin ceros después de 100000 intentos');
    }

    Polynomial generatedPrivateKey = Polynomial(noise);

    final fixedValue = Polynomial.fixed();
    Polynomial generatedPublicKey = generatedPrivateKey.multiply(fixedValue, 3329);

    return KyberKeyPair._(generatedPublicKey, generatedPrivateKey);
  }

  static Uint8List _generateSeed(int length) {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  }
}
