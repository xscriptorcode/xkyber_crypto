// gen_matrix.dart
//
// Generates the A (or A^T) matrix of dimension KYBER_K x KYBER_K using publicseed.
// If transposed = false, generates A normal, if true, A transposed.
// Based on the polyuniform function described in the Kyber specification.
//
// Requires:
// - polyuniform (implemented in poly.dart)
// - KYBER_K, KYBER_SYMBYTES (in params.dart)
// - shake128 in shake.dart

import 'dart:typed_data';
import 'params.dart';
import 'poly.dart';


List<List<Poly>> genMatrix(Uint8List seed, bool transposed) {
  List<List<Poly>> A = List<List<Poly>>.generate(
    KYBER_K,
    (_) => List<Poly>.generate(KYBER_K, (_) => Poly()),
  );

  for (int i = 0; i < KYBER_K; i++) {
    for (int j = 0; j < KYBER_K; j++) {
      if (transposed) {
        polyuniform(A[j][i], seed, (j << 8) + i);
      } else {
        polyuniform(A[i][j], seed, (i << 8) + j);
      }
    }
  }
  return A;
}