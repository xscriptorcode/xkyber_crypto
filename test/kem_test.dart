//testfile only for test
// kem_test.dart
// ignore_for_file: always_specify_types

import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';
import 'package:collection/collection.dart';
import 'dart:developer';

/// This function tests the Kyber Key Encapsulation Mechanism (KEM) by:
///   1. Generating a keypair (publicKey, privateKey)
///   2. Encapsulating a shared secret using the public key
///   3. Decapsulating the shared secret using the private key
///   4. Verifying that the shared secrets match
///
/// The test is successful if the shared secrets match. Otherwise, the test fails.
void testKEM() {
  Uint8List pk = Uint8List(KYBER_PUBLICKEYBYTES);
  Uint8List sk = Uint8List(KYBER_SECRETKEYBYTES);
  cryptokemkeypair(pk, sk);

  Uint8List c = Uint8List(KYBER_CIPHERTEXTBYTES);
  Uint8List ssenc = Uint8List(KYBER_SSBYTES);
  cryptokemenc(c, ssenc, pk);

  Uint8List ssdec = Uint8List(KYBER_SSBYTES);
  cryptokemdec(ssdec, c, sk);

  if (ListEquality().equals(ssenc, ssdec)) {
    log("Kem test passed");
  } else {
    log("Kem test failed");
  }
}
