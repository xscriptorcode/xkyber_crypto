// kyber_kem.dart
//
// Ahora que tenemos la lógica real en kem.dart, este archivo puede ser un wrapper.

import 'dart:typed_data';
import 'params.dart';
import 'kem.dart';

class KyberEncapsulationResult {
  final Uint8List ciphertextKEM;
  final Uint8List sharedSecret;
  KyberEncapsulationResult(this.ciphertextKEM, this.sharedSecret);
}

class KyberKEM {
  // Genera keypair real
  static KyberEncapsulationResult encapsulate(Uint8List pk) {
    Uint8List c = Uint8List(KYBER_CIPHERTEXTBYTES);
    Uint8List ss = Uint8List(KYBER_SSBYTES);
    crypto_kem_enc(c, ss, pk);
    return KyberEncapsulationResult(c, ss);
  }

  static Uint8List decapsulate(Uint8List c, Uint8List sk) {
    Uint8List ss = Uint8List(KYBER_SSBYTES);
    crypto_kem_dec(ss, c, sk);
    return ss;
  }
}
