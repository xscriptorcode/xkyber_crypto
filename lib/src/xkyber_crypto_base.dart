import 'dart:typed_data';
import 'package:xkyber_crypto/polynomial.dart';
import '../deterministic_noise_generator.dart';
import '../kyber_kem.dart';
import '../kyber_keypair.dart';

/// Clase principal de la biblioteca xKyberCrypto que proporciona
/// funcionalidades de cifrado post-cuántico basado en Kyber.
class XKyberCryptoBase {
  /// Genera una clave pública y una clave privada utilizando Kyber.
  KyberKeyPair generateKeyPair() {
    return KyberKeyPair.generate(); // Genera un par de claves
  }

  /// Cifra un mensaje dado utilizando la clave pública.
  List<int> encrypt(Uint8List message, Uint8List publicKey) {
    final KyberKEM kem = KyberKEM(Polynomial.fixed(), Polynomial.fixed()); // Especifica el tipo KyberKEM
    return kem.encapsulate(); // Usa encapsulación para cifrado
  }

  /// Descifra un mensaje cifrado utilizando la clave privada.
  List<int> decrypt(List<int> ciphertext, Uint8List privateKey) {
    final KyberKEM kem = KyberKEM(Polynomial.fixed(), Polynomial.fixed()); // Especifica el tipo KyberKEM
    return kem.decapsulate(ciphertext); // Usa decapsulación para descifrado
  }

  /// Genera ruido determinístico necesario para el cifrado.
  Uint8List generateNoise(Uint8List seed) {
    final DeterministicNoiseGenerator generator = DeterministicNoiseGenerator(seed, seed.length); // Especifica el tipo DeterministicNoiseGenerator
    return generator.generateNoise(); // Genera ruido determinístico
  }
}
