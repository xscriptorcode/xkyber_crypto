// reduce.dart
// Functions for modular reduction for Kyber.
// Based on the reference implementation (PQClean).

import 'params.dart';

int barrettReduce(int a) {
  // Constant v = floor((1<<26 + KYBER_Q/2) / KYBER_Q) = 20159.
  const int v = 20159;
  int t = ((a * v) >> 26);
  int r = a - t * KYBER_Q;
  return r;
}

int montgomeryReduce(int a) {
  // R = 2^16 = 65536.
  int t = (a * KYBER_QINV) % 65536;
  int r = (a + t * KYBER_Q) ~/ 65536;
  if (r >= KYBER_Q) {
    r -= KYBER_Q;
  }
  return r;
}

int csubq(int x) {
  if (x >= KYBER_Q) {
    x -= KYBER_Q;
  }
  return x;
}
