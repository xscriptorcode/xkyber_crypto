// indcpa.dart

import 'dart:typed_data';
import 'params.dart';
import 'poly.dart';
import 'polyvec.dart';
import 'shake.dart';
import 'randombytes.dart';
import 'gen_matrix.dart'; // Import donde está genMatrix

void indcpakeypair(Uint8List pk, Uint8List sk) {
  Uint8List seed = randombytes(KYBER_SYMBYTES);
  Uint8List seedbuf = shake128(seed, KYBER_SYMBYTES * 2);
  Uint8List publicseed = seedbuf.sublist(0, KYBER_SYMBYTES);
  Uint8List noiseseed = seedbuf.sublist(KYBER_SYMBYTES, 2 * KYBER_SYMBYTES);

  List<List<Poly>> A = genMatrix(publicseed, false);
  PolyVec s = PolyVec();
  PolyVec e = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    polygetnoise(s.vec[i], noiseseed, i);
    polygetnoise(e.vec[i], noiseseed, i + KYBER_K);
  }

  polyvecntt(s);
  polyvecntt(e);

  PolyVec pkvec = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    pkvec.vec[i] = Poly();
    for (int j = 0; j < KYBER_K; j++) {
      Poly t = polybasemul(A[i][j], s.vec[j]);
      if (j == 0) {
        pkvec.vec[i] = t;
      } else {
        pkvec.vec[i] = polyadd(pkvec.vec[i], t);
      }
    }
    pkvec.vec[i] = polyadd(pkvec.vec[i], e.vec[i]);
  }

  Uint8List pkpv = polyveccompress(pkvec);
  for (int i = 0; i < pkpv.length; i++) {
    pk[i] = pkpv[i];
  }
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    pk[KYBER_POLYVECCOMPRESSEDBYTES + i] = publicseed[i];
  }

  Uint8List skpv = polyvectobytes(s);
  for (int i = 0; i < skpv.length; i++) {
    sk[i] = skpv[i];
  }
}

void indcpaenc(Uint8List c, Uint8List m, Uint8List pk, Uint8List coins) {
  Uint8List publicseed = pk.sublist(KYBER_POLYVECCOMPRESSEDBYTES,
      KYBER_POLYVECCOMPRESSEDBYTES + KYBER_SYMBYTES);
  PolyVec pkvec =
      polyvecdecompress(pk.sublist(0, KYBER_POLYVECCOMPRESSEDBYTES));

  List<List<Poly>> at = genMatrix(publicseed, true);

  PolyVec r = PolyVec();
  PolyVec e1 = PolyVec();
  Poly e2 = Poly();
  for (int i = 0; i < KYBER_K; i++) {
    polygetnoise(r.vec[i], coins, i);
    polygetnoise(e1.vec[i], coins, i + KYBER_K);
  }
  polygetnoise(e2, coins, 2 * KYBER_K);

  polyvecntt(r);

  PolyVec u = PolyVec();
  for (int i = 0; i < KYBER_K; i++) {
    u.vec[i] = Poly();
    for (int j = 0; j < KYBER_K; j++) {
      Poly t = polybasemul(at[i][j], r.vec[j]);
      if (j == 0) {
        u.vec[i] = t;
      } else {
        u.vec[i] = polyadd(u.vec[i], t);
      }
    }
    u.vec[i] = polyadd(u.vec[i], e1.vec[i]);
  }

  Poly v = Poly();
  v.coeffs.fillRange(0, KYBER_N, 0);
  for (int i = 0; i < KYBER_K; i++) {
    Poly t = polybasemul(pkvec.vec[i], r.vec[i]);
    v = polyadd(v, t);
  }

  polyfrommsg(e2, m);
  v = polyadd(v, e2);

  Uint8List ubytes = polyveccompress(u);
  Uint8List vbytes = polycompress(v);

  for (int i = 0; i < ubytes.length; i++) {
    c[i] = ubytes[i];
  }
  for (int i = 0; i < vbytes.length; i++) {
    c[ubytes.length + i] = vbytes[i];
  }
}

void indcpadec(Uint8List m, Uint8List c, Uint8List sk) {
  PolyVec u = polyvecdecompress(c.sublist(0, KYBER_POLYVECCOMPRESSEDBYTES));
  Poly v = polydecompress(c.sublist(KYBER_POLYVECCOMPRESSEDBYTES));

  PolyVec s = polyvecfrombytes(sk);

  Poly tmp = Poly();
  tmp.coeffs.fillRange(0, KYBER_N, 0);
  for (int i = 0; i < KYBER_K; i++) {
    Poly t = polybasemul(u.vec[i], s.vec[i]);
    tmp = polyadd(tmp, t);
  }

  Poly mp = polysub(v, tmp);
  polytomsg(m, mp);
}
