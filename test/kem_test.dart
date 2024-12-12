import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';
import 'package:collection/collection.dart';
import 'dart:developer';

void testKEM() {
  Uint8List pk = Uint8List(KYBER_PUBLICKEYBYTES);
  Uint8List sk = Uint8List(KYBER_SECRETKEYBYTES);
  crypto_kem_keypair(pk, sk);

  Uint8List c = Uint8List(KYBER_CIPHERTEXTBYTES);
  Uint8List ss_enc = Uint8List(KYBER_SSBYTES);
  crypto_kem_enc(c, ss_enc, pk);

  Uint8List ss_dec = Uint8List(KYBER_SSBYTES);
  crypto_kem_dec(ss_dec, c, sk);

  if (ListEquality().equals(ss_enc, ss_dec)) {
    log("Kem test passed");
  } else {
    log("Kem test failed");
  }
}
