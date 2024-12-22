// reduce.dart
//
// Functions for reducing modulo q for Kyber.
// Based on the reference implementation (PQClean).
// Parameters: q = 3329, for Kyber512.
//
// Key functions:
// - barrettreduce: Barrett reduction
// - montgomeryreduce: Montgomery reduction
// - fqmul: multiplication in the field modulo q using Montgomery
//
// QINV: modular inverse of q modulo 2^16, such that q * QINV ≡ -1 (mod 2^16).
// For q=3329, QINV=62209 according to the reference implementation.

import 'params.dart';

// follows the parameter convention in the specification
// ignore: constant_identifier_names
const int QINV = 62209; // -q^{-1} mod 2^16 para q=3329

/// Barrett reduce reduces the value 'a' modulo q using the Barrett approximation.
/// This ensures the result is in [0, q-1].
int barrettreduce(int a) {
  // Barrett reduction according to PQClean:
  // Given q=3329, the derived constants are used for the reduction.
  //
  // Formula: a' = a - floor(a * v / 2^26) * q
  // where v = floor((2^26 + q/2)/q)

  const int v = ((1 << 26) + (KYBER_Q >> 1)) ~/ KYBER_Q;
  int t = (v * a) >> 26;
  t *= KYBER_Q;
  return a - t;
}

/// Montgomery reduce reduces a number a modulo q and reverses the Montgomery transform.
/// It serves for efficient modular multiplications in the Montgomery domain.
int montgomeryreduce(int a) {
  // According to PQClean:
  // u = a * QINV mod 2^16
  // t = (a - u*q) >> 16
  // returns t in [0,q-1] if a < q*2^16

  int u = (a * QINV) & 0xFFFF; // sólo tomar los 16 bits bajos
  int t = a - u * KYBER_Q;
  t >>= 16;
  return t;
}

/// fqmul multiplies a*b modulo q using montgomeryreduce.
/// It assumes that a and b are already reduced and in the range [0,q).
int fqmul(int a, int b) {
  return montgomeryreduce(a * b);
}
