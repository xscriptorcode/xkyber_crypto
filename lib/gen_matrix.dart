// gen_matrix.dart
//
// Genera la matriz A (o A^T) de dimensión KYBER_K x KYBER_K usando publicseed.
// Si transposed = false, genera A normal, si true, A transpuesta.
// Se basa en la función poly_uniform descrita en la especificación de Kyber.
//
// Requiere:
// - poly_uniform (implementada en poly.dart)
// - KYBER_K, KYBER_SYMBYTES (en params.dart)
// - shake128 en shake.dart

import 'dart:typed_data';
import 'params.dart';
import 'poly.dart';

List<List<Poly>> genMatrix(Uint8List seed, bool transposed) {
  List<List<Poly>> A = List.generate(KYBER_K, (_) => List.generate(KYBER_K, (_) => Poly()));
  for (int i = 0; i < KYBER_K; i++) {
    for (int j = 0; j < KYBER_K; j++) {
      if (transposed) {
        poly_uniform(A[j][i], seed, (j << 8) + i);
      } else {
        poly_uniform(A[i][j], seed, (i << 8) + j);
      }
    }
  }
  return A;
}
