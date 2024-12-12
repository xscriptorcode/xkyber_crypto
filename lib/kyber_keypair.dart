// kyber_keypair.dart
//
// Ahora que tenemos la lógica completa en kem.dart/indcpa.dart, generaremos la keypair real.
// Esto es un ejemplo, ya que Kyber realmente no devuelve polinomios aquí, sino pk/sk en bytes.
// Ajustaremos para que devuelva pk y sk en bytes, al estilo real de Kyber.

import 'dart:typed_data';
import 'params.dart';
import 'kem.dart';

class KyberKeyPair {
  final Uint8List publicKey;
  final Uint8List secretKey;

  KyberKeyPair._(this.publicKey, this.secretKey);

  factory KyberKeyPair.generate() {
    Uint8List pk = Uint8List(KYBER_PUBLICKEYBYTES);
    Uint8List sk = Uint8List(KYBER_SECRETKEYBYTES);
    crypto_kem_keypair(pk, sk);
    return KyberKeyPair._(pk, sk);
  }
}
