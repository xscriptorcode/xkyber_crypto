// verify.dart
//
// This file provides functions to perform certain operations
// in constant time, avoiding information leakage through
// side channels such as execution time.
//
// These functions are critical for the security of Kyber in its IND-CCA2
// mode, since they ensure that the response of the decryption does not
// depend on subtle differences when the input is incorrect.
//
// "verify" compares two byte arrays in constant time.
// "cmov" conditionally copies a vector to another, also in constant time.

import 'dart:typed_data';

/// Compares two byte arrays [a] and [b] in constant time.
/// Returns `true` if they are identical, `false` otherwise.
/// This function avoids early exits that could leak information.
bool verify(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  int r = 0;
  for (int i = 0; i < a.length; i++) {
    r |= a[i] ^ b[i];
  }
  return r == 0;
}

/// Copies the contents of [x] to [r] if [b] is 1, otherwise does nothing.
/// The operation is performed in constant time, without its time varying
/// depending on the data, only on the length.
///
/// - [r]: destination buffer.
/// - [x]: source buffer.
/// - [len]: amount of bytes to copy.
/// - [b]: control bit (0 or 1).
void cmov(Uint8List r, Uint8List x, int len, int b) {
  // If b=1, we need to copy x into r.
  // If b=0, we don't copy anything.
  // Convert b to -b & 0xFF to create a full mask if b=1.
  b = -b & 0xFF;
  for (int i = 0; i < len; i++) {
    r[i] ^= b & (r[i] ^ x[i]);
  }
}
