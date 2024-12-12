// indcpa.dart

import 'dart:typed_data';
import 'params.dart';
import 'poly.dart';
import 'polyvec.dart';
import 'shake.dart';
import 'randombytes.dart';
import 'gen_matrix.dart';  // Import donde está genMatrix

void indcpa_keypair(Uint8List pk, Uint8List sk) {
  Uint8List seed = randombytes(KYBER_SYMBYTES);
  Uint8List seedbuf = shake128(seed, KYBER_SYMBYTES*2);
  Uint8List publicseed = seedbuf.sublist(0, KYBER_SYMBYTES);
  Uint8List noiseseed = seedbuf.sublist(KYBER_SYMBYTES, 2*KYBER_SYMBYTES);

  List<List<Poly>> A = genMatrix(publicseed, false);
  PolyVec s = PolyVec();
  PolyVec e = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    poly_getnoise(s.vec[i], noiseseed, i);
    poly_getnoise(e.vec[i], noiseseed, i+KYBER_K);
  }

  polyvec_ntt(s);
  polyvec_ntt(e);

  PolyVec pkvec = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    pkvec.vec[i] = Poly();
    for (int j = 0; j < KYBER_K; j++) {
      Poly t = poly_basemul(A[i][j], s.vec[j]);
      if (j == 0) {
        pkvec.vec[i] = t;
      } else {
        pkvec.vec[i] = poly_add(pkvec.vec[i], t);
      }
    }
    pkvec.vec[i] = poly_add(pkvec.vec[i], e.vec[i]);
  }

  Uint8List pkpv = polyvec_compress(pkvec);
  for (int i = 0; i < pkpv.length; i++) {
    pk[i] = pkpv[i];
  }
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    pk[KYBER_POLYVECCOMPRESSEDBYTES + i] = publicseed[i];
  }

  Uint8List skpv = polyvec_tobytes(s);
  for (int i = 0; i < skpv.length; i++) {
    sk[i] = skpv[i];
  }
}

void indcpa_enc(Uint8List c, Uint8List m, Uint8List pk, Uint8List coins) {
  Uint8List publicseed = pk.sublist(KYBER_POLYVECCOMPRESSEDBYTES, KYBER_POLYVECCOMPRESSEDBYTES+KYBER_SYMBYTES);
  PolyVec pkvec = polyvec_decompress(pk.sublist(0, KYBER_POLYVECCOMPRESSEDBYTES));

  List<List<Poly>> At = genMatrix(publicseed, true);

  PolyVec r = PolyVec();
  PolyVec e1 = PolyVec();
  Poly e2 = Poly();
  for (int i = 0; i < KYBER_K; i++) {
    poly_getnoise(r.vec[i], coins, i);
    poly_getnoise(e1.vec[i], coins, i+KYBER_K);
  }
  poly_getnoise(e2, coins, 2*KYBER_K);

  polyvec_ntt(r);

  PolyVec u = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    u.vec[i] = Poly();
    for (int j = 0; j < KYBER_K; j++) {
      Poly t = poly_basemul(At[i][j], r.vec[j]);
      if (j == 0) {
        u.vec[i] = t;
      } else {
        u.vec[i] = poly_add(u.vec[i], t);
      }
    }
    u.vec[i] = poly_add(u.vec[i], e1.vec[i]);
  }

  Poly v = Poly();
  v.coeffs.fillRange(0, KYBER_N, 0);
  for (int i = 0; i < KYBER_K; i++) {
    Poly t = poly_basemul(pkvec.vec[i], r.vec[i]);
    v = poly_add(v, t);
  }

  poly_frommsg(e2, m);
  v = poly_add(v, e2);

  Uint8List ubytes = polyvec_compress(u);
  Uint8List vbytes = poly_compress(v);

  for (int i = 0; i < ubytes.length; i++) {
    c[i] = ubytes[i];
  }
  for (int i = 0; i < vbytes.length; i++) {
    c[ubytes.length + i] = vbytes[i];
  }
}

void indcpa_dec(Uint8List m, Uint8List c, Uint8List sk) {
  PolyVec u = polyvec_decompress(c.sublist(0, KYBER_POLYVECCOMPRESSEDBYTES));
  Poly v = poly_decompress(c.sublist(KYBER_POLYVECCOMPRESSEDBYTES));

  PolyVec s = polyvec_frombytes(sk);

  Poly tmp = Poly();
  tmp.coeffs.fillRange(0, KYBER_N, 0);
  for (int i = 0; i < KYBER_K; i++) {
    Poly t = poly_basemul(u.vec[i], s.vec[i]);
    tmp = poly_add(tmp, t);
  }

  Poly mp = poly_sub(v, tmp);
  poly_tomsg(m, mp);
}
