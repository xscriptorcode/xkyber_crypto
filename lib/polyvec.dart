// polyvec.dart
//
// Maneja vectores de polinomios. Para Kyber_k=2 (Kyber512), un polyvec es [poly, poly].
// Estas funciones se basan en la especificación de Kyber y en implementaciones de referencia (ej: PQClean).
//
// Funciones principales:
// - polyvec_tobytes / polyvec_frombytes: Serializar/Deserializar un vector de polinomios.
// - polyvec_compress / polyvec_decompress: Comprimir/Descomprimir el vector de polinomios.
// - polyvec_ntt / polyvec_invntt_tomont: Transformar a dominio NTT y volver al dominio original.
// - polyvec_reduce: Reducir todos los coeficientes mod q.
// - polyvec_add: Sumar dos polyvec componente a componente.

import 'params.dart';
import 'poly.dart';
import 'dart:typed_data';

class PolyVec {
  List<Poly> vec;
  PolyVec() : vec = List.generate(KYBER_K, (_) => Poly());
}

/// Convierte un polyvec a bytes. Cada polinomio se convierte con poly_tobytes y se concatena.
Uint8List polyvec_tobytes(PolyVec v) {
  // poly_tobytes produce KYBER_POLYBYTES bytes por polinomio
  Uint8List r = Uint8List(KYBER_POLYVECBYTES);
  for (int i = 0; i < KYBER_K; i++) {
    Uint8List t = poly_tobytes(v.vec[i]);
    r.setRange(i * KYBER_POLYBYTES, (i + 1) * KYBER_POLYBYTES, t);
  }
  return r;
}

/// Convierte bytes a polyvec, asumiendo el formato producido por polyvec_tobytes.
PolyVec polyvec_frombytes(Uint8List r) {
  PolyVec v = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    v.vec[i] = poly_frombytes(r.sublist(i * KYBER_POLYBYTES, (i + 1) * KYBER_POLYBYTES));
  }
  return v;
}

/// Aplica poly_compress a cada polinomio y concatena.
Uint8List polyvec_compress(PolyVec v) {
  Uint8List r = Uint8List(KYBER_POLYVECCOMPRESSEDBYTES);
  for (int i = 0; i < KYBER_K; i++) {
    Uint8List t = poly_compress(v.vec[i]);
    r.setRange(i * KYBER_POLYCOMPRESSEDBYTES, (i + 1) * KYBER_POLYCOMPRESSEDBYTES, t);
  }
  return r;
}

/// Descomprime un polyvec desde bytes usando poly_decompress en cada polinomio.
PolyVec polyvec_decompress(Uint8List r) {
  PolyVec v = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    v.vec[i] = poly_decompress(r.sublist(i * KYBER_POLYCOMPRESSEDBYTES, (i + 1) * KYBER_POLYCOMPRESSEDBYTES));
  }
  return v;
}

/// Aplica NTT a cada polinomio en el vector.
void polyvec_ntt(PolyVec v) {
  for (int i = 0; i < KYBER_K; i++) {
    poly_ntt(v.vec[i]);
  }
}

/// Aplica la iNTT (inversa NTT) a cada polinomio en el vector.
void polyvec_invntt_tomont(PolyVec v) {
  for (int i = 0; i < KYBER_K; i++) {
    poly_invntt_tomont(v.vec[i]);
  }
}

/// Reduce todos los coeficientes en cada polinomio mod q.
void polyvec_reduce(PolyVec v) {
  for (int i = 0; i < KYBER_K; i++) {
    poly_reduce(v.vec[i]);
  }
}

/// Suma componente a componente dos polyvec.
PolyVec polyvec_add(PolyVec a, PolyVec b) {
  PolyVec r = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    r.vec[i] = poly_add(a.vec[i], b.vec[i]);
  }
  return r;
}
