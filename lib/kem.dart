// kem.dart
//
// Real implementation of crypto_kem_* following the Kyber512 standard.
// Based on PQClean and the official specification.
//
// Flow:
// cryptokemkeypair:
//   - generate IND-CPA keypair
//   - store pk, sk
//   - hash pk and store in sk
//   - generate random z, store in sk
//
// cryptokemenc:
//   - generate random m of SYMBYTES
//   - hash m => m'
//
//   - K = hash(m' || pk)
//   - coins = hash(K || m')
//
//   - c = indcpaenc(m', pk, coins)
//   - ss = hash(K || c)
//
// cryptokemdec:
//   - m' = indcpadec(c, sk)
//   - K' = hash(m' || pk)
//   - coins' = hash(K' || m')
//   - c' = indcpaenc(m', pk, coins')
//   - if c' == c then ss = hash(K' || c)
//              else ss = hash(Z || c) (Z is the seed stored in sk)

import 'dart:typed_data';
import 'params.dart';
import 'indcpa.dart';
import 'shake.dart';
import 'randombytes.dart';
import 'verify.dart';

/// Generates a Kyber key pair consisting of a public key `pk` and a private key `sk`.
///
/// The function first generates an IND-CPA key pair and stores the public key `pk` and
/// the private key `sk`. It then hashes the public key and appends this hash to the private key.
/// Next, it generates a random value `z` and appends it to the private key. The function returns
/// 0 upon successful execution.
///
/// Parameters:
/// - `pk`: The public key, which must have space for `KYBER_PUBLICKEYBYTES` bytes.
/// - `sk`: The private key, which must have space for `KYBER_SECRETKEYBYTES` bytes.
///
/// Returns:
/// - `int`: Always returns 0, indicating success.

int cryptokemkeypair(Uint8List pk, Uint8List sk) {
  // generate IND-CPA keypair
  indcpakeypair(pk, sk);

  // store pk at the end of sk
  for (int i = 0; i < KYBER_PUBLICKEYBYTES; i++) {
    sk[KYBER_SECRETKEYBYTES - KYBER_PUBLICKEYBYTES - KYBER_SYMBYTES + i] =
        pk[i];
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
    sk[KYBER_SECRETKEYBYTES - KYBER_SYMBYTES * 2 + i] = z[i];
  }

  return 0;
}

/// Encapsulates a shared secret `ss` using public key `pk` and produces ciphertext `c`.
///
/// The algorithm generates a random message `m` of length `KYBER_SYMBYTES`, and then
/// computes `mh = shake128(m, KYBER_SYMBYTES)`. The key `K = shake128(mh || pk, KYBER_SYMBYTES)`
/// is then generated, and the coins `coins = shake(K || mh, KYBER_SYMBYTES)` are computed.
/// The ciphertext `c` is then computed as `c = indcpaenc(mh, pk, coins)`.
/// Finally, the shared secret `ss = shake(K || c, KYBER_SSBYTES)` is computed and returned.
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

  /// Decapsulates the shared secret `ss` from ciphertext `c` using private key `sk`.
  ///
  /// The algorithm first extracts the public key `pk`, hash of `pk`, and random value `z` from `sk`.
  /// Then, it computes `m' = indcpadec(c, sk)`, `K' = hash(m' || pk)`, `coins' = hash(K' || m')`, and
  /// `c' = indcpaenc(m', pk, coins')`. If `c' == c`, then `ss = hash(K' || c)`, otherwise `ss = hash(z || c)`.
  /// The shared secret `ss` is then returned.
int cryptokemdec(Uint8List ss, Uint8List c, Uint8List sk) {
  // extract pk, hashPk, z from sk
  Uint8List pk = sk.sublist(
      KYBER_SECRETKEYBYTES - KYBER_PUBLICKEYBYTES - KYBER_SYMBYTES,
      KYBER_SECRETKEYBYTES - KYBER_SYMBYTES);
  // Uint8List hashPk = sk.sublist(KYBER_SECRETKEYBYTES - KYBER_SYMBYTES, KYBER_SECRETKEYBYTES);
  Uint8List z = sk.sublist(KYBER_SECRETKEYBYTES - 2 * KYBER_SYMBYTES,
      KYBER_SECRETKEYBYTES - KYBER_SYMBYTES * 2 + KYBER_SYMBYTES);

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

  // If fail = 0 => ss = hash(K' || c)
  // If fail = 1 => ss = hash(z || c)
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
