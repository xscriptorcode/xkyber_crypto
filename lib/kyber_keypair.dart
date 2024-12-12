// kyber_keypair.dart
//
// Now that we have the complete logic in kem.dart/indcpa.dart, we generate the real keypair.
// We will adjust it to return pk and sk in bytes, like the real Kyber.

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
    cryptokemkeypair(pk, sk);
    return KyberKeyPair._(pk, sk);
  }
}
