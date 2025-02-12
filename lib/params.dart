// params.dart
// ignore_for_file: constant_identifier_names
//
// Parameters for Kyber512 IND-CPA variant (public key: 288 bytes, secret key: 1632 bytes).
// Based on the official Kyber specification (Kyber512):
//
// Kyber512:
// - k = 2
// - n = 256
// - q = 3329
// - η = 2
//
// The following constants define sizes (in bytes) for keys, ciphertext, polynomials, etc.

/// Number of polynomials in the key vector.
const int KYBER_K = 2;

/// Degree of each polynomial.
const int KYBER_N = 256;

/// Modulus q.
const int KYBER_Q = 3329;

/// Inverse of q modulo 2^16.
const int KYBER_QINV = 62209;

/// Noise parameter η.
const int KYBER_ETA = 2;

/// Size in bytes of seeds and symmetric keys.
const int KYBER_SYMBYTES = 32; // Seed size (e.g., for SHAKE)
const int KYBER_SSBYTES = 32; // Shared secret key size

/// Sizes of keys and ciphertexts for IND-CPA variant.
const int KYBER_PUBLICKEYBYTES =
    800; // Public key: 256 (polyvec compressed) + 32 (seed)
const int KYBER_SECRETKEYBYTES = 1632; // Secret key size in bytes.
const int KYBER_CIPHERTEXTBYTES = 768; // Ciphertext size in bytes.

/// Sizes related to polynomials.
/// A full polynomial is represented in 384 bytes using 12-bit encoding per coefficient.
/// (256 coefficients × 12 bits = 3072 bits; 3072 / 8 = 384 bytes)
const int KYBER_POLYBYTES = 384;

/// A compressed polynomial is represented in 128 bytes when compressing each coefficient
/// to 3 bits (256 coefficients × 3 bits = 768 bits; 768 / 8 = 96 bytes in some implementations,
/// but for IND-CPA in Kyber512 the reference PQClean uses 128 bytes per polynomial).
const int KYBER_POLYCOMPRESSEDBYTES = 128;

/// Derived sizes:
const int KYBER_POLYVECBYTES = KYBER_K * KYBER_POLYBYTES;
const int KYBER_POLYVECCOMPRESSEDBYTES =
    KYBER_K * KYBER_POLYCOMPRESSEDBYTES; // 2 * 128 = 256

/// Specific sizes for the internal IND-CPA KEM.
/// The IND-CPA public key is formed by concatenating a compressed polyvec and a seed.
const int KYBER_INDCPA_PUBLICKEYBYTES =
    KYBER_POLYVECCOMPRESSEDBYTES + KYBER_SYMBYTES; // 256 + 32 = 288
const int KYBER_INDCPA_SECRETKEYBYTES = KYBER_POLYVECBYTES;
const int KYBER_INDCPA_BYTES =
    KYBER_POLYVECCOMPRESSEDBYTES + KYBER_POLYCOMPRESSEDBYTES;

/// Compression bit-lengths used in encoding u and v in the ciphertext.
/// For this implementation, a full polynomial is encoded using 12 bits per coefficient,
/// and the compressed polynomial uses 3 bits per coefficient.
const int KYBER_DU = 12;
const int KYBER_DV = 3;

/// Final scaling factor in Montgomery domain (represents 1/256).
const int KYBER_F = 1441;
