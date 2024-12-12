// lib/crypto/constant_time_comparison.dart

import 'dart:typed_data';

/// Performs a constant time comparison between two byte arrays to prevent side channel attacks.
bool constantTimeCompare(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  int result = 0;
  for (int i = 0; i < a.length; i++) {
    result |= a[i] ^ b[i];
  }
  return result == 0;
}
