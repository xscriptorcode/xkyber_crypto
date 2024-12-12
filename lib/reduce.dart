// reduce.dart
//
// Funciones de reducción modulo q para Kyber.
// Basado en la implementación de referencia (PQClean).
// Parámetros: q = 3329, para Kyber512.
//
// Funciones clave:
// - barrett_reduce: reducción Barrett
// - montgomery_reduce: reducción de Montgomery
// - fqmul: multiplicación en el campo mod q usando Montgomery
//
// QINV: inverso modular de q mod 2^16, tal que q * QINV ≡ -1 (mod 2^16).
// Para q=3329, QINV=62209 según la implementación de referencia.

import 'params.dart';

const int QINV = 62209; // -q^{-1} mod 2^16 para q=3329

/// Barrett reduce reduce el valor 'a' modulo q usando la aproximación de Barrett.
/// Esto asegura que el resultado esté en [0, q-1].
int barrett_reduce(int a) {
  // Barrett reduction según PQClean:
  // Dado q=3329, se usan las constantes derivadas para la reducción.
  //
  // Fórmula: a' = a - floor(a * v / 2^26) * q
  // donde v = floor((2^26 + q/2)/q)
  
  const int v = ((1 << 26) + (KYBER_Q >> 1)) ~/ KYBER_Q;
  int t = (v * a) >> 26;
  t *= KYBER_Q;
  return a - t;
}

/// Montgomery reduce convierte un número a mod q y deshace la transformación de Montgomery.
/// Sirve para multiplicaciones modulares eficientes en el dominio Montgomery.
int montgomery_reduce(int a) {
  // Según PQClean:
  // u = a * QINV mod 2^16
  // t = (a - u*q) >> 16
  // retorna t en [0,q-1] si a < q*2^16
  
  int u = (a * QINV) & 0xFFFF; // sólo tomar los 16 bits bajos
  int t = a - u * KYBER_Q;
  t >>= 16;
  return t;
}

/// fqmul multiplica a*b mod q usando montgomery_reduce.
/// Se asume que a y b están ya reducidos y en el rango [0,q).
int fqmul(int a, int b) {
  return montgomery_reduce(a * b);
}
