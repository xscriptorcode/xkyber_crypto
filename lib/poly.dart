// poly.dart
//
// Functions for manipulating polynomials in Kyber. Each polynomial has KYBER_N coefficients modulo KYBER_Q.
// This file implements functions for noise sampling, serialization (12-bit encoding), compression (3-bit),
// NTT transforms, arithmetic, message encoding, and uniform polynomial generation.

import 'dart:typed_data';
import 'params.dart';
import 'reduce.dart';
import 'ntt.dart';
import 'shake.dart';
import 'fq.dart';

class Poly {
  List<int> coeffs;
  Poly() : coeffs = List<int>.filled(KYBER_N, 0);
}

/// Generates a pseudorandom polynomial from a seed and nonce using SHAKE128 and CBD.
void polygetnoise(Poly r, Uint8List seed, int nonce) {
  Uint8List extseed = Uint8List(KYBER_SYMBYTES + 1);
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    extseed[i] = seed[i];
  }
  extseed[KYBER_SYMBYTES] = nonce;
  // For η=2 and KYBER_N=256, (2*256)/4 = 128 bytes are generated.
  Uint8List buf = shake128(extseed, (KYBER_ETA * KYBER_N) ~/ 4);
  cbd(r, buf);
}

/// Implements the Centered Binomial Distribution for η=2.
void cbd(Poly r, Uint8List buf) {
  for (int i = 0; i < KYBER_N ~/ 8; i++) {
    int t = buf[2 * i] | (buf[2 * i + 1] << 8);
    for (int j = 0; j < 8; j++) {
      int aj = (t >> j) & 1;
      int bj = (t >> (j + 8)) & 1;
      r.coeffs[8 * i + j] = aj - bj;
    }
  }
}

/// Serializes a polynomial into a byte array using 12-bit encoding per coefficient.
Uint8List polytobytes(Poly a) {
  Uint8List r = Uint8List(KYBER_POLYBYTES);
  Poly t = polyreduce(Poly()..coeffs = List<int>.from(a.coeffs));
  for (int i = 0; i < KYBER_N ~/ 2; i++) {
    int t0 = t.coeffs[2 * i];
    int t1 = t.coeffs[2 * i + 1];
    r[3 * i + 0] = t0 & 0xFF;
    r[3 * i + 1] = ((t0 >> 8) & 0x0F) | ((t1 & 0x0F) << 4);
    r[3 * i + 2] = t1 >> 4;
  }
  return r;
}

/// Deserializes a polynomial from a byte array using 12-bit encoding.
Poly polyfrombytes(Uint8List r) {
  Poly a = Poly();
  for (int i = 0; i < KYBER_N ~/ 2; i++) {
    int t0 = r[3 * i + 0] | ((r[3 * i + 1] & 0x0F) << 8);
    int t1 = (r[3 * i + 1] >> 4) | (r[3 * i + 2] << 4);
    a.coeffs[2 * i] = t0;
    a.coeffs[2 * i + 1] = t1;
  }
  return a;
}

/// Compresses a polynomial into a compact byte array using 3 bits per coefficient.
Uint8List polycompress(Poly a) {
  Uint8List r = Uint8List(KYBER_POLYCOMPRESSEDBYTES);
  Poly t = polyreduce(Poly()..coeffs = List<int>.from(a.coeffs));
  int pos = 0;
  for (int i = 0; i < KYBER_N; i += 8) {
    int t0 = (((t.coeffs[i] << 3) + (KYBER_Q >> 1)) ~/ KYBER_Q) & 0x7;
    int t1 = (((t.coeffs[i + 1] << 3) + (KYBER_Q >> 1)) ~/ KYBER_Q) & 0x7;
    int t2 = (((t.coeffs[i + 2] << 3) + (KYBER_Q >> 1)) ~/ KYBER_Q) & 0x7;
    int t3 = (((t.coeffs[i + 3] << 3) + (KYBER_Q >> 1)) ~/ KYBER_Q) & 0x7;
    int t4 = (((t.coeffs[i + 4] << 3) + (KYBER_Q >> 1)) ~/ KYBER_Q) & 0x7;
    int t5 = (((t.coeffs[i + 5] << 3) + (KYBER_Q >> 1)) ~/ KYBER_Q) & 0x7;
    int t6 = (((t.coeffs[i + 6] << 3) + (KYBER_Q >> 1)) ~/ KYBER_Q) & 0x7;
    int t7 = (((t.coeffs[i + 7] << 3) + (KYBER_Q >> 1)) ~/ KYBER_Q) & 0x7;
    int packed = t0 |
        (t1 << 3) |
        (t2 << 6) |
        (t3 << 9) |
        (t4 << 12) |
        (t5 << 15) |
        (t6 << 18) |
        (t7 << 21);
    r[pos + 0] = packed & 0xFF;
    r[pos + 1] = (packed >> 8) & 0xFF;
    r[pos + 2] = (packed >> 16) & 0xFF;
    pos += 3;
  }
  return r;
}

/// Decompresses a polynomial from its compressed byte array representation.
Poly polydecompress(Uint8List r) {
  Poly a = Poly();
  int pos = 0;
  for (int i = 0; i < KYBER_N; i += 8) {
    int packed = r[pos] | (r[pos + 1] << 8) | (r[pos + 2] << 16);
    pos += 3;
    int d0 = (packed >> 0) & 0x7;
    int d1 = (packed >> 3) & 0x7;
    int d2 = (packed >> 6) & 0x7;
    int d3 = (packed >> 9) & 0x7;
    int d4 = (packed >> 12) & 0x7;
    int d5 = (packed >> 15) & 0x7;
    int d6 = (packed >> 18) & 0x7;
    int d7 = (packed >> 21) & 0x7;
    a.coeffs[i + 0] = (d0 * KYBER_Q + 4) >> 3;
    a.coeffs[i + 1] = (d1 * KYBER_Q + 4) >> 3;
    a.coeffs[i + 2] = (d2 * KYBER_Q + 4) >> 3;
    a.coeffs[i + 3] = (d3 * KYBER_Q + 4) >> 3;
    a.coeffs[i + 4] = (d4 * KYBER_Q + 4) >> 3;
    a.coeffs[i + 5] = (d5 * KYBER_Q + 4) >> 3;
    a.coeffs[i + 6] = (d6 * KYBER_Q + 4) >> 3;
    a.coeffs[i + 7] = (d7 * KYBER_Q + 4) >> 3;
  }
  return a;
}

/// Applies the NTT transform to a polynomial.
void polyntt(Poly a) {
  a.coeffs = ntt(a.coeffs);
}

/// Applies the inverse NTT transform (returning the polynomial in standard representation).
void polyinvntttomont(Poly a) {
  a.coeffs = invntt(a.coeffs);
}

/// Component-wise multiplication of two polynomials in Montgomery domain.
Poly polybasemul(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqmul(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

/// Component-wise addition of two polynomials.
Poly polyadd(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqadd(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

/// Component-wise subtraction of two polynomials.
Poly polysub(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqsub(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

/// Reduces all coefficients of a polynomial modulo KYBER_Q.
Poly polyreduce(Poly a) {
  for (int i = 0; i < KYBER_N; i++) {
    a.coeffs[i] = barrettReduce(a.coeffs[i]);
  }
  return a;
}

/// Converts a message (byte array) into a polynomial.
/// Each bit of the message is mapped to a coefficient in the polynomial.
/// If the bit is 1, the corresponding coefficient is set to KYBER_Q/2; otherwise, 0.
void polyfrommsg(Poly p, Uint8List msg) {
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    for (int j = 0; j < 8; j++) {
      int bit = (msg[i] >> j) & 1;
      p.coeffs[8 * i + j] = bit * (KYBER_Q ~/ 2);
    }
  }
}

/// Converts a polynomial into a message (byte array).
/// Groups of 8 coefficients are converted back into a single byte.
void polytomsg(Uint8List msg, Poly p) {
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    msg[i] = 0;
    for (int j = 0; j < 8; j++) {
      int t = p.coeffs[8 * i + j];
      t = (t + (KYBER_Q ~/ 2)) % KYBER_Q;
      int bit = ((2 * t) ~/ KYBER_Q) & 1;
      msg[i] |= (bit << j);
    }
  }
}

/// Generates a uniform polynomial from a seed and nonce using SHAKE128.
void polyuniform(Poly a, Uint8List seed, int nonce) {
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
      int t = (buf[pos] | (buf[pos + 1] << 8) | (buf[pos + 2] << 16)) & 0xFFF;
      if (t < KYBER_Q) {
        a.coeffs[ctr++] = t;
      }
      pos += 3;
    }
  }
}
