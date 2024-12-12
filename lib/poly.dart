// poly.dart
//
// Functions for manipulating polynomials in Kyber. Each polynomial has 256 coefficients modulo q.
// Includes:
// - polygetnoise (noise sampling with cbd)
// - polytobytes, polyfrombytes (serialization)
// - polycompress, polydecompress (compression)
// - polyntt, polyinvntttomont (NTT transforms)
// - polybasemul (pointwise multiplication in NTT)
// - polyadd, polysub, polyreduce (basic arithmetic operations)
// - polyfrommsg, polytomsg (message encoding in polynomials)
// - polyuniform (generates pseudorandom polynomials from a seed)
// - cbd (Centered Binomial Distribution)

import 'dart:typed_data';
import 'params.dart';
import 'reduce.dart';
import 'ntt.dart';
import 'fq.dart';
import 'shake.dart';

class Poly {
  List<int> coeffs;
  Poly() : coeffs = List<int>.filled(KYBER_N, 0);
}


/// Generates a pseudorandom polynomial from a seed and nonce using SHAKE128
/// and CBD (Centered Binomial Distribution). The output is a polynomial with
/// coefficients in the range [-(q-1)/2, (q-1)/2].
///
/// The function takes a seed and nonce as input, and returns a polynomial
/// with coefficients in the range [-(q-1)/2, (q-1)/2].
///
/// The output is a pseudorandom polynomial with coefficients in the range
/// [-(q-1)/2, (q-1)/2].
///
/// The function uses the SHAKE128 function to produce a sequence of pseudorandom
/// bytes from the seed and nonce, and then uses the CBD to generate a polynomial
/// with coefficients in the range [-(q-1)/2, (q-1)/2].
///
/// The function takes O(1) time and O(1) space.
///
/// The function is deterministic, meaning that given the same seed and nonce,
/// it will always produce the same output.
void polygetnoise(Poly r, Uint8List seed, int nonce) {
  Uint8List extseed = Uint8List(KYBER_SYMBYTES + 1);
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    extseed[i] = seed[i];
  }
  extseed[KYBER_SYMBYTES] = nonce;

  Uint8List buf = shake128(extseed, (KYBER_ETA * KYBER_N) ~/ 4);
  // η=2 => 2*256/4 = 128 bytes

  cbd(r, buf);
}

/// Samples a polynomial from a uniform distribution using the
/// Centered Binomial Distribution (CBD) as described in the
/// Kyber specification.
///
/// The CBD samples a uniform distribution of polynomials with
/// coefficients in the range [-η, η] by sampling a uniform
/// distribution of two bytes, interpreting them as a 16-bit
/// unsigned integer, and then extracting the bits of the
/// integer to obtain the coefficients of the polynomial.
/// The coefficients are then divided by 2 to obtain the
/// final coefficients in the range [-η/2, η/2].
void cbd(Poly r, Uint8List buf) {
  // η=2 for Kyber512
  for (int i = 0; i < KYBER_N ~/ 8; i++) {
    int t = buf[2*i] | (buf[2*i+1] << 8);
    for (int j = 0; j < 8; j++) {
      int aj = (t >> j) & 1;
      int bj = (t >> (j+8)) & 1;
      r.coeffs[8*i+j] = aj - bj;
    }
  }
}

/// Serializes a polynomial into a byte array representation.
///
/// This function takes a polynomial `a` and maps each of its coefficients to two
/// bytes in the output array. The coefficients are processed in chunks of two
/// bytes, each being interpreted as a 16-bit unsigned integer. The resulting
/// `Uint8List` object has the serialized coefficients.
Uint8List polytobytes(Poly a) {
  Uint8List r = Uint8List(KYBER_POLYBYTES);
  Poly t = polyreduce(Poly()..coeffs = List<int>.from(a.coeffs));
  for (int i = 0; i < KYBER_N; i++) {
    int val = t.coeffs[i];
    r[2 * i] = val & 0xFF;
    r[2 * i + 1] = (val >> 8) & 0xFF;
  }
  return r;
}


/// Deserializes a polynomial from a byte array representation.
///
/// This function takes a byte array `r` and interprets it as a sequence of
/// coefficients in the polynomial. The coefficients are extracted from the
/// byte array in chunks of two bytes, each being interpreted as a 16-bit
/// unsigned integer. The resulting `Poly` object has the deserialized
/// coefficients.
Poly polyfrombytes(Uint8List r) {
  Poly a = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    a.coeffs[i] = r[2*i] | (r[2*i+1] << 8);
  }
  return a;
}

/// Compresses a polynomial into a byte array representation.
///
/// This function takes a polynomial `a` and reduces its coefficients before
/// compressing them into a compact byte array format. The polynomial is processed
/// in chunks of four coefficients, each being mapped to a 10-bit value. These
/// values are packed into a sequence of bytes, with five bytes encoding four 
/// coefficients. The resulting byte array is suitable for storage or transmission
/// in applications where space efficiency is critical.
///
/// - Parameter a: The polynomial to be compressed.
/// - Returns: A byte array containing the compressed representation of the polynomial.
Uint8List polycompress(Poly a) {
  Uint8List r = Uint8List(KYBER_POLYCOMPRESSEDBYTES);
  Poly t = polyreduce(Poly()..coeffs = List<int>.from(a.coeffs));
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

/// Decompresses a polynomial from a compressed byte representation.
///
/// This function takes a compressed byte array `r` and reconstructs the polynomial
/// `a` by decompressing each sequence of bytes into four coefficients. The coefficients
/// are extracted from the bit-packed format in `r`, where each group of five bytes
/// represents four 10-bit coefficients. The decompressed coefficients are converted
/// to the original polynomial domain by scaling them with `KYBER_Q` and normalizing.
///
/// - Parameters:
///   - r: A byte array containing the compressed representation of the polynomial.
/// - Returns: A `Poly` object with coefficients decompressed from the input byte array.
Poly polydecompress(Uint8List r) {
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

/// Applies the Number Theoretic Transform (NTT) to a polynomial `a` in-place.
/// 
/// This function transforms the input polynomial `a` to the NTT domain using
/// the precomputed roots of unity (`zetas`). The coefficients of the polynomial
/// are modified in-place to reflect the NTT transformation, which is useful
/// for efficient polynomial multiplication.
/// 
/// - Parameter a: The input polynomial to be transformed.
void polyntt(Poly a) {
  a.coeffs = ntt(a.coeffs);
}

/// Inverse NTT transform of a polynomial, in the Montgomery domain, with the result reduced modulo q.
///
/// The input polynomial `a` is transformed in-place. The output is a new polynomial in the standard
/// domain that is the inverse NTT transform of the input polynomial.
///
/// This function is the inverse of `polyntt`. It uses the precomputed zetas for the inverse NTT
/// and then normalizes the output by multiplying each coefficient by nInv (computed in ntt.dart),
/// as described in the reference implementation (PQClean) and the Kyber specification.
void polyinvntttomont(Poly a) {
  a.coeffs = invntt(a.coeffs);
  // In PQClean, nInv is already multiplied inside invntt, we did the same here.
}

/// Returns a new polynomial `r` which is the component-wise multiplication of polynomials `a` and `b`
/// in the Montgomery domain.
Poly polybasemul(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqmul(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

/// Returns a new polynomial `r` which is the component-wise sum of polynomials `a` and `b`.
///
/// This function iterates over all coefficients in the polynomials `a` and `b`, 
/// adding corresponding coefficients together using modular addition. 
/// The result is a new polynomial `r` where each coefficient `r[i]` is computed as:
/// `r[i] = a[i] + b[i] mod q`.
///
/// - Parameters:
///   - a: The first input polynomial.
///   - b: The second input polynomial.
/// - Returns: A new polynomial with coefficients that are the sum of the corresponding
///   coefficients in `a` and `b`, reduced modulo `q`.
Poly polyadd(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqadd(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

/// Returns a new polynomial r = a - b, i.e. for each coefficient, r[i] = a[i] - b[i] mod q.
Poly polysub(Poly a, Poly b) {
  Poly r = Poly();
  for (int i = 0; i < KYBER_N; i++) {
    r.coeffs[i] = fqsub(a.coeffs[i], b.coeffs[i]);
  }
  return r;
}

/// Reduces all coefficients of a polynomial mod q.
///
/// This function iterates over all coefficients in the polynomial `a` and applies
/// the Barrett reduction algorithm to each coefficient, reducing it modulo `q`.
/// The result is a new polynomial with coefficients that are all reduced modulo `q`.
///
Poly polyreduce(Poly a) {
  for (int i = 0; i < KYBER_N; i++) {
    a.coeffs[i] = barrettreduce(a.coeffs[i]);
  }
  return a;
}

/// Converts a message byte array `msg` into a polynomial `p`.
///
/// This function interprets each byte in the message `msg` as a series
/// of 8 bits, where each bit is mapped to a coefficient in the polynomial `p`.
/// If the bit is set (1), the corresponding coefficient in `p` is set to
/// `KYBER_Q / 2`. If the bit is not set (0), the coefficient is set to 0.
/// 
/// The message `msg` is expected to have `KYBER_SYMBYTES` bytes, resulting
/// in a polynomial `p` with coefficients that encode the message.
/// 
/// - Parameters:
///   - p: The polynomial to be populated with coefficients based on the message.
///   - msg: A byte array representing the message to be encoded into the polynomial.
void polyfrommsg(Poly p, Uint8List msg) {
  for (int i = 0; i < KYBER_SYMBYTES; i++) {
    for (int j = 0; j < 8; j++) {
      int bit = (msg[i] >> j) & 1;
      p.coeffs[8*i+j] = bit * (KYBER_Q ~/ 2);
    }
  }
}

/// Converts a polynomial `p` into a message byte array `msg`.
///
/// This function iterates over the coefficients of the polynomial `p`
/// and reconstructs the original message by interpreting groups of 8
/// coefficients as the bits of a byte. Each coefficient contributes
/// one bit to the message byte, determined by its proximity to `KYBER_Q / 2`.
///
/// The output message `msg` will have `KYBER_SYMBYTES` bytes, reflecting
/// the polynomial's encoded message form.
void polytomsg(Uint8List msg, Poly p) {
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

/// Generates a pseudorandom polynomial `a` from a given `seed` and `nonce`.
///
/// This function uses the SHAKE128 function to produce a sequence of pseudorandom
/// bytes from the `seed` combined with the `nonce`. The output bytes are then used
/// to populate the coefficients of the polynomial `a`, ensuring each coefficient
/// is less than `KYBER_Q`.
///
/// The `extseed` is an extended version of the `seed` which includes the `nonce`
/// as its last two bytes. The function iteratively fills the polynomial by
/// extracting 12-bit values from the randomized byte buffer until all coefficients
/// are populated.
///
/// - Parameters:
///   - a: The polynomial to be populated with pseudorandom coefficients.
///   - seed: A byte array used to seed the pseudorandom generator.
///   - nonce: An integer value used to diversify the pseudorandom output.
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
      int t = (buf[pos] | (buf[pos+1]<<8) | (buf[pos+2]<<16)) & 0xFFF;
      if (t < KYBER_Q) {
        a.coeffs[ctr++] = t;
      }
      pos += 3;
    }
  }
}
