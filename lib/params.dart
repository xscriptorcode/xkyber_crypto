// params.dart
// ignore_for_file: constant_identifier_names
// Ignoring constant identifier name rule to follow the naming convention of the Kyber specification
//
// Parameters for Kyber512, which approximates AES-128 security level.
// These values are based on the official Kyber specification:
//
// Kyber512:
// - k=2
// - n=256
// - q=3329
// - η=2
//
// Key sizes, ciphertext size and other values are taken from the official documentation.
//
// Reference: https://pq-crystals.org/kyber/

// Number of polynomials in the key vector
const int KYBER_K = 2;        

// Degree of the polynomial (Kyber uses polynomials of degree n=256)
const int KYBER_N = 256;      

// Module q
const int KYBER_Q = 3329;     

// Noise parameter η
const int KYBER_ETA = 2;      

// Sizes in bytes of seeds and keys
const int KYBER_SYMBYTES = 32;    // Seed size (e.g. for SHAKE)
const int KYBER_SSBYTES = 32;     // Shared secret key size

// Sizes of keys and ciphertext
const int KYBER_PUBLICKEYBYTES = 800;   // public key size in bytes
const int KYBER_SECRETKEYBYTES = 1632;  // secret key size in bytes
const int KYBER_CIPHERTEXTBYTES = 768;  // ciphertext size in bytes

// Sizes related to polynomials
const int KYBER_POLYBYTES = 384;                // A full polynomial takes up 384 bytes
const int KYBER_POLYCOMPRESSEDBYTES = 96;       // A compressed polynomial takes up 96 bytes
const int KYBER_POLYVECBYTES = KYBER_K * KYBER_POLYBYTES;
const int KYBER_POLYVECCOMPRESSEDBYTES = KYBER_K * KYBER_POLYCOMPRESSEDBYTES;

// Specific sizes for the internal IND-CPA KEM
const int KYBER_INDCPA_PUBLICKEYBYTES = KYBER_POLYVECCOMPRESSEDBYTES + KYBER_SYMBYTES;
const int KYBER_INDCPA_SECRETKEYBYTES = KYBER_POLYVECBYTES;
const int KYBER_INDCPA_BYTES = KYBER_POLYVECCOMPRESSEDBYTES + KYBER_POLYCOMPRESSEDBYTES;

// Compression bits used in the encoding of u and v in the ciphertext
const int KYBER_DU = 10;
const int KYBER_DV = 4;

// All these parameters follow the official Kyber documentation.
