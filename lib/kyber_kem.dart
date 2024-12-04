// lib/crypto/kyber_kem.dart

import 'dart:typed_data';
import 'polynomial.dart';
import 'deterministic_noise_generator.dart';
import 'polynomial_compression.dart';
import 'constant_time_comparison.dart';

class KyberKEM {
  final Polynomial publicKey;
  final Polynomial privateKey;

  KyberKEM(this.publicKey, this.privateKey);

  /// Encapsula el mensaje y genera una clave compartida utilizando compresión y ruido determinista.
  List<int> encapsulate() {
    // Genera ruido determinista para el polinomio utilizando la semilla de la clave pública
    final noiseGenerator = DeterministicNoiseGenerator(
        Uint8List.fromList(publicKey.coefficients),
        publicKey.coefficients.length);
    final noise = noiseGenerator.generateNoise();
    Polynomial sharedKey = publicKey.multiply(Polynomial(noise), 3329);

    // Comprime el polinomio resultante para el envío
    final compressedSharedKey =
        compressPolynomial(sharedKey.coefficients, 10, 3329);
    return compressedSharedKey;
  }

  /// Descapsula el mensaje cifrado y reconstruye la clave compartida.
  List<int> decapsulate(List<int> ciphertext) {
    // Descomprime el polinomio del mensaje cifrado
    final decompressedCiphertext = decompressPolynomial(ciphertext, 10, 3329);
    Polynomial ciphertextPoly =
        Polynomial(Uint8List.fromList(decompressedCiphertext));
    Polynomial sharedKey = privateKey.multiply(ciphertextPoly, 3329);

    // Compara en tiempo constante para verificar integridad
    if (!constantTimeCompare(Uint8List.fromList(ciphertextPoly.coefficients),
        Uint8List.fromList(sharedKey.coefficients))) {
      throw Exception("Error en descifrado: verificación fallida.");
    }

    return sharedKey.coefficients;
  }
}
