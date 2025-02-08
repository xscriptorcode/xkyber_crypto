// ntt.dart
// Kyber NTT, Montgomery conversion, and related functions.
// Based on the PQClean implementation for Kyber512.

import 'dart:core';
import 'params.dart';
import 'reduce.dart';

/// Precomputed Montgomery constant: R^2 mod KYBER_Q.
/// For KYBER_Q = 3329 and R = 2^16, the reference value is 2285.
const int R2 = 2285;

/// Local aliases for convenience.
final int q = KYBER_Q;
final int qinv = KYBER_QINV;
final int n = KYBER_N;
final int f = KYBER_F; // Final scaling factor.

/// Multiplication in the field modulo KYBER_Q using Montgomery reduction.
int fqmul(int a, int b) {
  return montgomeryReduce(a * b);
}

/// Converts an integer x into Montgomery representation.
int toMontgomery(int x) {
  return fqmul(x, R2);
}

/// Converts an integer x from Montgomery representation back to standard representation.
int fromMontgomery(int x) {
  return montgomeryReduce(x);
}

/// =============================================
/// Official zetas with 129 elements (only indices 1..127 used in forward NTT)
/// =============================================
final List<int> zetasOficial = <int>[
  2285, 340, 1017, 1352, 203, 1441, 2048, 360,
  1637, 1351, 503, 1105, 2646, 2114, 1223, 1477,
  286, 202, 118, 1478, 1897, 2022, 1553, 2806,
  1707, 123, 1421, 598, 2879, 1817, 1721, 446,
  1318, 1187, 2411, 2010, 3221, 547, 1638, 1660,
  204, 315, 3231, 802, 732, 1143, 2926, 2395,
  2236, 3152, 2008, 987, 123, 1398, 3118, 740,
  436, 2732, 1027, 1266, 2706, 151, 1165, 2555,
  1181, 3155, 2018, 468, 2590, 741, 2404, 2025,
  1241, 2717, 101, 2401, 1107, 2241, 3302, 781,
  1721, 1028, 264, 2309, 2801, 2104, 1002, 188,
  2021, 3050, 176, 2757, 1104, 2793, 1451, 2627,
  2982, 1028, 1375, 1937, 2911, 1092, 2665, 2556,
  3151, 1031, 2024, 716, 264, 104, 2710, 1200,
  1826, 1887, 1444, 90, 2781, 1268, 2474, 3222,
  2641, 1763, 867, 2871, 2023, 1871, 585, 1085,
  2285
];

/// =============================================
/// Bit-reversal table for 256 coefficients
/// =============================================
final List<int> bitrevTable = <int>[
  0,128,64,192,32,160,96,224,16,144,80,208,48,176,112,240,
  8,136,72,200,40,168,104,232,24,152,88,216,56,184,120,248,
  4,132,68,196,36,164,100,228,20,148,84,212,52,180,116,244,
  12,140,76,204,44,172,108,236,28,156,92,220,60,188,124,252,
  2,130,66,194,34,162,98,226,18,146,82,210,50,178,114,242,
  10,138,74,202,42,170,106,234,26,154,90,218,58,186,122,250,
  6,134,70,198,38,166,102,230,22,150,86,214,54,182,118,246,
  14,142,78,206,46,174,110,238,30,158,94,222,62,190,126,254,
  1,129,65,193,33,161,97,225,17,145,81,209,49,177,113,241,
  9,137,73,201,41,169,105,233,25,153,89,217,57,185,121,249,
  5,133,69,197,37,165,101,229,21,149,85,213,53,181,117,245,
  13,141,77,205,45,173,109,237,29,157,93,221,61,189,125,253,
  3,131,67,195,35,163,99,227,19,147,83,211,51,179,115,243,
  11,139,75,203,43,171,107,235,27,155,91,219,59,187,123,251,
  7,135,71,199,39,167,103,231,23,151,87,215,55,183,119,247,
  15,143,79,207,47,175,111,239,31,159,95,223,63,191,127,255
];

/// =============================================
/// _nttInPlace (Forward Number Theoretic Transform)
/// =============================================
void _nttInPlace(List<int> poly) {
  int len, start, j, k;
  int t, zeta;
  k = 1;
  for (len = 128; len >= 2; len >>= 1) {
    for (start = 0; start < 256; start = j + len) {
      zeta = zetasOficial[k];
      k++;
      for (j = start; j < start + len; j++) {
        int t64 = poly[j + len] * zeta;
        t = montgomeryReduce(t64);
        int tmp = poly[j] + 4 * q - t;
        tmp = barrettReduce(tmp);
        tmp = csubq(tmp);
        poly[j + len] = tmp;
        int tmp2 = poly[j] + t;
        tmp2 = barrettReduce(tmp2);
        tmp2 = csubq(tmp2);
        poly[j] = tmp2;
      }
    }
  }
}

/// =============================================
/// _invnttInPlace (Inverse Number Theoretic Transform)
/// =============================================
void _invnttInPlace(List<int> poly) {
  int len, start, j, k;
  int t, zeta;
  k = 0;
  for (len = 2; len <= 128; len <<= 1) {
    for (start = 0; start < 256; start = j + len) {
      zeta = zetasInv[k];
      k++;
      for (j = start; j < start + len; j++) {
        t = poly[j];
        int tmp = t + poly[j + len];
        tmp = barrettReduce(tmp);
        tmp = csubq(tmp);
        poly[j] = tmp;
        int tmp2 = t + 4 * q - poly[j + len];
        tmp2 = barrettReduce(tmp2);
        tmp2 = csubq(tmp2);
        int mul = tmp2 * zeta;
        poly[j + len] = montgomeryReduce(mul);
      }
    }
  }
  for (int i = 0; i < 256; i++) {
    int prod = poly[i] * f;
    poly[i] = montgomeryReduce(prod);
  }
}

/// =============================================
/// Wrappers for the transforms
/// =============================================
List<int> ntt(List<int> inputPoly) {
  List<int> r = List<int>.from(inputPoly);
  bitrevVector(r);
  _nttInPlace(r);
  return r;
}

List<int> invntt(List<int> inputPoly) {
  List<int> r = List<int>.from(inputPoly);
  bitrevVector(r);
  _invnttInPlace(r);
  return r;
}

/// Bit-reversal permutation of a polynomial vector.
void bitrevVector(List<int> poly) {
  for (int i = 0; i < n; i++) {
    int j = bitrevTable[i];
    if (j > i) {
      int tmp = poly[i];
      poly[i] = poly[j];
      poly[j] = tmp;
    }
  }
}

/// =============================================
/// Precomputed inverse zetas for the inverse NTT.
/// =============================================
final List<int> zetasInv = List<int>.generate(127, (int i) {
  int forwardZeta = zetasOficial[127 - i];
  int invForwardZeta = modInverse(forwardZeta, q);
  return toMontgomery(invForwardZeta);
});

/// =============================================
/// Modular exponentiation.
int modExp(int base, int exp, int mod) {
  int result = 1;
  base = base % mod;
  while (exp > 0) {
    if ((exp & 1) == 1) {
      result = (result * base) % mod;
    }
    base = (base * base) % mod;
    exp >>= 1;
  }
  return result;
}

/// Modular inverse using Fermat's little theorem.
int modInverse(int a, int mod) {
  return modExp(a, mod - 2, mod);
}
