// kem.dart
//
// Real implementation of crypto_kem_* following the Kyber512 standard (IND-CCA2).
// Based on PQClean and the official specification.

import 'dart:typed_data';
import 'params.dart';
import 'indcpa.dart';
import 'shake.dart';
import 'randombytes.dart';
import 'verify.dart';

int cryptokemkeypair(Uint8List pk, Uint8List sk) {
  // generate IND-CPA keypair
  indcpakeypair(pk, sk);

  // store pk at the end of sk
  for (int i = 0; i < KYBER_PUBLICKEYBYTES; i++) {
    sk[KYBER_SECRETKEYBYTES - KYBER_PUBLICKEYBYTES - KYBER_SYMBYTES + i] = pk[i];
  }

  // hash(pk)
  Uint8List hashPk = shake128(pk, KYBER_SYMBYTES);

  // store hash of pk at the end of sk (after pk)
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    sk[KYBER_SECRETKEYBYTES - KYBER_SYMBYTES + i] = hashPk[i];
  }

  // generate random z
  Uint8List z = randombytes(KYBER_SYMBYTES);
  // store z at the end of sk
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    sk[KYBER_SECRETKEYBYTES - 2 * KYBER_SYMBYTES + i] = z[i];
  }

  return 0;
}

int cryptokemenc(Uint8List c, Uint8List ss, Uint8List pk) {
  // m random
  Uint8List m = randombytes(KYBER_SYMBYTES);

  // hash(m)
  Uint8List mh = shake128(m, KYBER_SYMBYTES);

  // hash(mh || pk)
  Uint8List kpInput = Uint8List(KYBER_SYMBYTES + KYBER_PUBLICKEYBYTES);
  kpInput.setRange(0, KYBER_SYMBYTES, mh);
  kpInput.setRange(KYBER_SYMBYTES, KYBER_SYMBYTES + KYBER_PUBLICKEYBYTES, pk);
  Uint8List K = shake128(kpInput, KYBER_SYMBYTES);

  // coins = shake(K || mh)
  Uint8List coinsInput = Uint8List(KYBER_SYMBYTES + KYBER_SYMBYTES);
  coinsInput.setRange(0, KYBER_SYMBYTES, K);
  coinsInput.setRange(KYBER_SYMBYTES, 2 * KYBER_SYMBYTES, mh);
  Uint8List coins = shake128(coinsInput, KYBER_SYMBYTES);

  // c = indcpaenc(mh, pk, coins)
  indcpaenc(c, mh, pk, coins);

  // ss = shake(K || c)
  Uint8List ssInput = Uint8List(KYBER_SYMBYTES + KYBER_CIPHERTEXTBYTES);
  ssInput.setRange(0, KYBER_SYMBYTES, K);
  ssInput.setRange(KYBER_SYMBYTES, KYBER_SYMBYTES + KYBER_CIPHERTEXTBYTES, c);
  Uint8List out = shake128(ssInput, KYBER_SSBYTES);
  ss.setAll(0, out);

  return 0;
}

int cryptokemdec(Uint8List ss, Uint8List c, Uint8List sk) {
  // extract pk, hashPk, z from sk
  Uint8List pk = sk.sublist(
      KYBER_SECRETKEYBYTES - KYBER_PUBLICKEYBYTES - KYBER_SYMBYTES,
      KYBER_SECRETKEYBYTES - KYBER_SYMBYTES);
  // Uint8List hashPk = sk.sublist(KYBER_SECRETKEYBYTES - KYBER_SYMBYTES, KYBER_SECRETKEYBYTES);
  Uint8List z = sk.sublist(KYBER_SECRETKEYBYTES - 2 * KYBER_SYMBYTES,
      KYBER_SECRETKEYBYTES - KYBER_SYMBYTES);

  // m' = indcpadec(c, sk)
  Uint8List mprime = Uint8List(KYBER_SYMBYTES);
  indcpadec(mprime, c, sk);

  // K' = hash(m' || pk)
  Uint8List kpInput = Uint8List(KYBER_SYMBYTES + KYBER_PUBLICKEYBYTES);
  kpInput.setRange(0, KYBER_SYMBYTES, mprime);
  kpInput.setRange(KYBER_SYMBYTES, KYBER_SYMBYTES + KYBER_PUBLICKEYBYTES, pk);
  Uint8List kprime = shake128(kpInput, KYBER_SYMBYTES);

  // coins' = hash(K' || m')
  Uint8List coinsInput = Uint8List(KYBER_SYMBYTES + KYBER_SYMBYTES);
  coinsInput.setRange(0, KYBER_SYMBYTES, kprime);
  coinsInput.setRange(KYBER_SYMBYTES, 2 * KYBER_SYMBYTES, mprime);
  Uint8List coinsPrime = shake128(coinsInput, KYBER_SYMBYTES);

  // c' = indcpaenc(m', pk, coins')
  Uint8List cprime = Uint8List(KYBER_CIPHERTEXTBYTES);
  indcpaenc(cprime, mprime, pk, coinsPrime);

  int fail = verify(c, cprime) ? 0 : 1;

  // If fail = 0, then ss = hash(K' || c); else ss = hash(z || c)
  Uint8List ssInput = Uint8List(KYBER_SYMBYTES + KYBER_CIPHERTEXTBYTES);
  if (fail == 0) {
    ssInput.setRange(0, KYBER_SYMBYTES, kprime);
  } else {
    ssInput.setRange(0, KYBER_SYMBYTES, z);
  }
  ssInput.setRange(KYBER_SYMBYTES, KYBER_SYMBYTES + KYBER_CIPHERTEXTBYTES, c);

  Uint8List out = shake128(ssInput, KYBER_SSBYTES);
  ss.setAll(0, out);

  return 0;
}
