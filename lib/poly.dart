// poly.dart
//
// Funciones para manipular polinomios en Kyber. Cada polinomio tiene 256 coeficientes mod q.
// Incluye:
// - poly_getnoise (muestreo de ruido con cbd)
// - poly_tobytes, poly_frombytes (serialización)
// - poly_compress, poly_decompress (compresión)
// - poly_ntt, poly_invntt_tomont (transformadas NTT)
// - poly_basemul (multiplicación punto a punto en NTT)
// - poly_add, poly_sub, poly_reduce (operaciones aritméticas básicas)
// - poly_frommsg, poly_tomsg (codificación de mensajes en polinomios)
// - poly_uniform (genera polinomios pseudoaleatorios a partir de una semilla)
// - cbd (Centered Binomial Distribution)

import 'dart:typed_data';
import 'params.dart';
import 'reduce.dart';
import 'ntt.dart';
import 'fq.dart';
import 'shake.dart';

class Poly {
  List<int> coeffs;
  Poly() : coeffs = List.filled(KYBER_N, 0);
}

void poly_getnoise(Poly r, Uint8List seed, int nonce) {
  Uint8List extseed = Uint8List(KYBER_SYMBYTES + 1);
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    extseed[i] = seed[i];
  }
  extseed[KYBER_SYMBYTES] = nonce;

  Uint8List buf = shake128(extseed, (KYBER_ETA * KYBER_N) ~/ 4);
  // η=2 => 2*256/4 = 128 bytes

  cbd(r, buf);
}

void cbd(Poly r, Uint8List buf) {
  // η=2 para Kyber512
  for (int i = 0; i < KYBER_N ~/ 8; i++) {
    int t = buf[2*i] | (buf[2*i+1] << 8);
    for (int j = 0; j < 8; j++) {
      int a_j = (t >> j) & 1;
      int b_j = (t >> (j+8)) & 1;
      r.coeffs[8*i+j] = a_j - b_j;
    }
  }
}

Uint8List poly_tobytes(Poly a) {
  Uint8List r = Uint8List(KYBER_POLYBYTES);
  Poly t = poly_reduce(Poly()..coeffs=List.from(a.coeffs));
  for (int i = 0; i < KYBER_N; i++) {
    int val = t.coeffs[i];
    r[2*i]   = val & 0xFF;
    r[2*i+1] = (val >> 8) & 0xFF;
  }
  return r;
}

Poly poly_frombytes(Uint8List r) {
  Poly a = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    a.coeffs[i] = r[2*i] | (r[2*i+1] << 8);
  }
  return a;
}

Uint8List poly_compress(Poly a) {
  Uint8List r = Uint8List(KYBER_POLYCOMPRESSEDBYTES);
  Poly t = poly_reduce(Poly()..coeffs=List.from(a.coeffs));
  int pos = 0;
  for (int i = 0; i < KYBER_N; i += 4) {
    int d0 = ((t.coeffs[i] << 10) + (KYBER_Q >> 1)) ~/ KYBER_Q & 0x3FF;
    int d1 = ((t.coeffs[i+1] << 10) + (KYBER_Q >> 1)) ~/ KYBER_Q & 0x3FF;
    int d2 = ((t.coeffs[i+2] << 10) + (KYBER_Q >> 1)) ~/ KYBER_Q & 0x3FF;
    int d3 = ((t.coeffs[i+3] << 10) + (KYBER_Q >> 1)) ~/ KYBER_Q & 0x3FF;

    int packed = d0 | (d1 << 10) | (d2 << 20) | ((d3 & 0x3F) << 30);
    r[pos]   = packed & 0xFF;
    r[pos+1] = (packed >> 8) & 0xFF;
    r[pos+2] = (packed >> 16) & 0xFF;
    r[pos+3] = (packed >> 24) & 0xFF;
    r[pos+4] = (d3 >> 6) & 0xFF;
    pos += 5;
  }
  return r;
}

Poly poly_decompress(Uint8List r) {
  Poly a = Poly();
  int pos = 0;
  for (int i = 0; i < KYBER_N; i += 4) {
    int t0 = r[pos] | (r[pos+1]<<8) | (r[pos+2]<<16) | (r[pos+3]<<24);
    int t1 = r[pos+4];
    pos += 5;
    int d0 = t0 & 0x3FF;
    int d1 = (t0 >> 10) & 0x3FF;
    int d2 = (t0 >> 20) & 0x3FF;
    int d3 = ((t0 >> 30) & 0x03F) | ((t1 & 0xFF)<<6);

    a.coeffs[i]   = (d0 * KYBER_Q + (1<<9)) >> 10;
    a.coeffs[i+1] = (d1 * KYBER_Q + (1<<9)) >> 10;
    a.coeffs[i+2] = (d2 * KYBER_Q + (1<<9)) >> 10;
    a.coeffs[i+3] = (d3 * KYBER_Q + (1<<9)) >> 10;
  }
  return a;
}

void poly_ntt(Poly a) {
  a.coeffs = ntt(a.coeffs);
}

void poly_invntt_tomont(Poly a) {
  a.coeffs = invntt(a.coeffs);
  // En PQClean ya se multiplica por nInv dentro de invntt, aquí también lo hicimos.
}

Poly poly_basemul(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqmul(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

Poly poly_add(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqadd(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

Poly poly_sub(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqsub(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

Poly poly_reduce(Poly a) {
  for (int i = 0; i < KYBER_N; i++) {
    a.coeffs[i] = barrett_reduce(a.coeffs[i]);
  }
  return a;
}

void poly_frommsg(Poly p, Uint8List msg) {
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    for (int j = 0; j < 8; j++) {
      int bit = (msg[i] >> j) & 1;
      p.coeffs[8*i+j] = bit * (KYBER_Q ~/ 2);
    }
  }
}

void poly_tomsg(Uint8List msg, Poly p) {
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    msg[i] = 0;
    for (int j = 0; j < 8; j++) {
      int t = p.coeffs[8*i+j];
      t = (t + (KYBER_Q ~/ 2)) % KYBER_Q;
      int bit = ( (2*t) ~/ KYBER_Q ) & 1;
      msg[i] |= (bit << j);
    }
  }
}

void poly_uniform(Poly a, Uint8List seed, int nonce) {
  Uint8List extseed = Uint8List(KYBER_SYMBYTES + 2);
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    extseed[i] = seed[i];
  }
  extseed[KYBER_SYMBYTES] = nonce & 0xFF;
  extseed[KYBER_SYMBYTES + 1] = (nonce >> 8) & 0xFF;

  int ctr = 0;
  while (ctr < KYBER_N) {
    int needed = (KYBER_N - ctr) * 3;
    if (needed < 168) {
      needed = 168;
    }

    Uint8List buf = shake128(extseed, needed);

    int pos = 0;
    while (pos + 3 <= buf.length && ctr < KYBER_N) {
      int t = (buf[pos] | (buf[pos+1]<<8) | (buf[pos+2]<<16)) & 0xFFF;
      if (t < KYBER_Q) {
        a.coeffs[ctr++] = t;
      }
      pos += 3;
    }
  }
}
