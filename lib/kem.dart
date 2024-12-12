// kem.dart
//
// Implementación real de crypto_kem_* siguiendo Kyber512 estándar.
// Basado en PQClean y la especificación oficial.
//
// Flujo:
// crypto_kem_keypair:
//   - indcpa_keypair
//   - almacenar pk, sk
//   - hashear pk y almacenar en sk
//   - generar z aleatorio, almacenar en sk
//
// crypto_kem_enc:
//   - generar m aleatorio SYMBYTES
//   - hash m => m'
//
//   - K = hash(m' || pk)
//   - coins = hash(K || m')
//
//   - c = indcpa_enc(m', pk, coins)
//   - ss = hash(K || c)
//
// crypto_kem_dec:
//   - m' = indcpa_dec(c, sk)
//   - K' = hash(m' || pk)
//   - coins' = hash(K' || m')
//   - c' = indcpa_enc(m', pk, coins')
//   - if c' == c then ss = hash(K' || c)
//              else ss = hash(Z || c) (Z es la semilla guardada en sk)

import 'dart:typed_data';
import 'params.dart';
import 'indcpa.dart';
import 'shake.dart';
import 'randombytes.dart';
import 'verify.dart';

int crypto_kem_keypair(Uint8List pk, Uint8List sk) {
  // Generar IND-CPA keypair
  indcpa_keypair(pk, sk);

  // almacenar pk al final de sk
  for (int i = 0; i < KYBER_PUBLICKEYBYTES; i++) {
    sk[KYBER_SECRETKEYBYTES - KYBER_PUBLICKEYBYTES - KYBER_SYMBYTES + i] = pk[i];
  }

  // hash(pk)
  Uint8List hashPk = shake128(pk, KYBER_SYMBYTES);

  // almacenar hashPk al final de sk (después de pk)
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    sk[KYBER_SECRETKEYBYTES - KYBER_SYMBYTES + i] = hashPk[i];
  }

  // generar z aleatorio
  Uint8List z = randombytes(KYBER_SYMBYTES);
  // almacenar z al final de sk
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    sk[KYBER_SECRETKEYBYTES - KYBER_SYMBYTES*2 + i] = z[i];
  }

  return 0;
}

int crypto_kem_enc(Uint8List c, Uint8List ss, Uint8List pk) {
  // m aleatorio
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
  coinsInput.setRange(KYBER_SYMBYTES, 2*KYBER_SYMBYTES, mh);
  Uint8List coins = shake128(coinsInput, KYBER_SYMBYTES);

  // c = indcpa_enc(mh, pk, coins)
  indcpa_enc(c, mh, pk, coins);

  // ss = shake(K || c)
  Uint8List ssInput = Uint8List(KYBER_SYMBYTES + KYBER_CIPHERTEXTBYTES);
  ssInput.setRange(0, KYBER_SYMBYTES, K);
  ssInput.setRange(KYBER_SYMBYTES, KYBER_SYMBYTES+KYBER_CIPHERTEXTBYTES, c);
  Uint8List out = shake128(ssInput, KYBER_SSBYTES);
  ss.setAll(0, out);

  return 0;
}

int crypto_kem_dec(Uint8List ss, Uint8List c, Uint8List sk) {
  // extraer pk, hashPk, z desde sk
  Uint8List pk = sk.sublist(KYBER_SECRETKEYBYTES - KYBER_PUBLICKEYBYTES - KYBER_SYMBYTES, KYBER_SECRETKEYBYTES - KYBER_SYMBYTES);
  Uint8List hashPk = sk.sublist(KYBER_SECRETKEYBYTES - KYBER_SYMBYTES, KYBER_SECRETKEYBYTES);
  Uint8List z = sk.sublist(KYBER_SECRETKEYBYTES - 2*KYBER_SYMBYTES, KYBER_SECRETKEYBYTES - KYBER_SYMBYTES*2 + KYBER_SYMBYTES);

  // m' = indcpa_dec(c, sk)
  Uint8List mprime = Uint8List(KYBER_SYMBYTES);
  indcpa_dec(mprime, c, sk);

  // K' = hash(m' || pk)
  Uint8List kpInput = Uint8List(KYBER_SYMBYTES + KYBER_PUBLICKEYBYTES);
  kpInput.setRange(0, KYBER_SYMBYTES, mprime);
  kpInput.setRange(KYBER_SYMBYTES, KYBER_SYMBYTES+KYBER_PUBLICKEYBYTES, pk);
  Uint8List Kprime = shake128(kpInput, KYBER_SYMBYTES);

  // coins' = hash(K' || m')
  Uint8List coinsInput = Uint8List(KYBER_SYMBYTES + KYBER_SYMBYTES);
  coinsInput.setRange(0, KYBER_SYMBYTES, Kprime);
  coinsInput.setRange(KYBER_SYMBYTES, 2*KYBER_SYMBYTES, mprime);
  Uint8List coinsPrime = shake128(coinsInput, KYBER_SYMBYTES);

  // c' = indcpa_enc(m', pk, coins')
  Uint8List cprime = Uint8List(KYBER_CIPHERTEXTBYTES);
  indcpa_enc(cprime, mprime, pk, coinsPrime);

  int fail = verify(c, cprime) ? 0 : 1;

  // If fail = 0 => ss = hash(K' || c)
  // If fail = 1 => ss = hash(z || c)
  Uint8List ssInput = Uint8List(KYBER_SYMBYTES + KYBER_CIPHERTEXTBYTES);
  if (fail == 0) {
    ssInput.setRange(0, KYBER_SYMBYTES, Kprime);
  } else {
    ssInput.setRange(0, KYBER_SYMBYTES, z);
  }
  ssInput.setRange(KYBER_SYMBYTES, KYBER_SYMBYTES+KYBER_CIPHERTEXTBYTES, c);
  
  Uint8List out = shake128(ssInput, KYBER_SSBYTES);
  ss.setAll(0, out);

  return 0;
}
