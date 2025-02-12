// kem_test.dart
// ignore_for_file: always_specify_types

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';
import 'package:collection/collection.dart';

void main() {
  group('Kyber KEM', () {
    test(
        'Keypair generation, encapsulation, and decapsulation produce matching shared secrets',
        () {
      // Generate keypair.
      final Uint8List pk = Uint8List(KYBER_PUBLICKEYBYTES);
      final Uint8List sk = Uint8List(KYBER_SECRETKEYBYTES);
      cryptokemkeypair(pk, sk);

      // Encapsulate using the public key.
      final Uint8List c = Uint8List(KYBER_CIPHERTEXTBYTES);
      final Uint8List ssEnc = Uint8List(KYBER_SSBYTES);
      cryptokemenc(c, ssEnc, pk);

      // Decapsulate using the secret key.
      final Uint8List ssDec = Uint8List(KYBER_SSBYTES);
      cryptokemdec(ssDec, c, sk);

      // Compare the shared secrets.
      final bool secretsEqual = const ListEquality().equals(ssEnc, ssDec);
      expect(secretsEqual, isTrue, reason: 'Shared secrets do not match.');
    });
  });
}
