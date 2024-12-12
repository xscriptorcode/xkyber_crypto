// polyvec.dart

import 'params.dart';
import 'poly.dart';
import 'dart:typed_data';

/// Main functions:
/// - polyvectobytes / polyvecfrombytes: Serialize/Deserialize a vector of polynomials.
/// - polyveccompress / polyvecdecompress: Compress/Decompress the vector of polynomials.
/// - polyvecntt / polyvecinvntttomont: Transform to NTT domain and back to original domain.
/// - polyvecreduce: Reduce all coefficients modulo q.
/// - polyvecadd: Add two polyvec component-wise.

class PolyVec {
  List<Poly> vec;
  PolyVec() : vec = List<Poly>.generate(KYBER_K, (_) => Poly());
}

/// Converts a polyvec to bytes. Each polynomial is converted with polytobytes and concatenated.
Uint8List polyvectobytes(PolyVec v) {
  // polytobytes produce KYBER_POLYBYTES bytes por polinomio
  Uint8List r = Uint8List(KYBER_POLYVECBYTES);
  for (int i = 0; i < KYBER_K; i++) {
    Uint8List t = polytobytes(v.vec[i]);
    r.setRange(i * KYBER_POLYBYTES, (i + 1) * KYBER_POLYBYTES, t);
  }
  return r;
}

/// Converts bytes to a polyvec, assuming the format produced by polyvectobytes.
PolyVec polyvecfrombytes(Uint8List r) {
  PolyVec v = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    v.vec[i] = polyfrombytes(r.sublist(i * KYBER_POLYBYTES, (i + 1) * KYBER_POLYBYTES));
  }
  return v;
}

/// Applies polycompress to each polynomial and concatenates.
Uint8List polyveccompress(PolyVec v) {
  Uint8List r = Uint8List(KYBER_POLYVECCOMPRESSEDBYTES);
  for (int i = 0; i < KYBER_K; i++) {
    Uint8List t = polycompress(v.vec[i]);
    r.setRange(i * KYBER_POLYCOMPRESSEDBYTES, (i + 1) * KYBER_POLYCOMPRESSEDBYTES, t);
  }
  return r;
}

/// Decompresses a polyvec from bytes using polydecompress on each polynomial.
PolyVec polyvecdecompress(Uint8List r) {
  PolyVec v = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    v.vec[i] = polydecompress(r.sublist(i * KYBER_POLYCOMPRESSEDBYTES, (i + 1) * KYBER_POLYCOMPRESSEDBYTES));
  }
  return v;
}

/// Applies NTT to each polynomial in the vector.
void polyvecntt(PolyVec v) {
  for (int i = 0; i < KYBER_K; i++) {
    polyntt(v.vec[i]);
  }
}

/// Applies the inverse NTT (iNTT) to each polynomial in the vector.
void polyvecinvntttomont(PolyVec v) {
  for (int i = 0; i < KYBER_K; i++) {
    polyinvntttomont(v.vec[i]);
  }
}

/// Reduce all coefficients in each polynomial modulo q.
void polyvecreduce(PolyVec v) {
  for (int i = 0; i < KYBER_K; i++) {
    polyreduce(v.vec[i]);
  }
}

/// Component-wise sum of two polyvecs.
PolyVec polyvecadd(PolyVec a, PolyVec b) {
  PolyVec r = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    r.vec[i] = polyadd(a.vec[i], b.vec[i]);
  }
  return r;
}
