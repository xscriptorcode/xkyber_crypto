// params.dart
//
// Parámetros para Kyber512, el nivel de seguridad que aproxima AES-128.
// Estos valores se basan en la especificación oficial de Kyber:
//
// Kyber512:
// - k=2
// - n=256
// - q=3329
// - η=2
//
// Tamaños de claves, ciphertext y demás se toman de la documentación oficial.
//
// Referencia: https://pq-crystals.org/kyber/

// Número de polinomios en el vector de claves
const int KYBER_K = 2;        

// Grado del polinomio (Kyber usa polinomios de grado n=256)
const int KYBER_N = 256;      

// Módulo q
const int KYBER_Q = 3329;     

// Parámetro de ruido η
const int KYBER_ETA = 2;      

// Tamaños en bytes de las semillas y claves
const int KYBER_SYMBYTES = 32;    // Tamaño de las semillas (ej: para SHAKE)
const int KYBER_SSBYTES = 32;     // Tamaño de la clave compartida (shared secret)

// Tamaños de claves y ciphertext
const int KYBER_PUBLICKEYBYTES = 800;   // tamaño de pk en bytes
const int KYBER_SECRETKEYBYTES = 1632;  // tamaño de sk en bytes
const int KYBER_CIPHERTEXTBYTES = 768;  // tamaño de ciphertext en bytes

// Tamaños relacionados con los polinomios
const int KYBER_POLYBYTES = 384;                // Un polinomio completo ocupa 384 bytes
const int KYBER_POLYCOMPRESSEDBYTES = 96;       // Un polinomio comprimido ocupa 96 bytes
const int KYBER_POLYVECBYTES = KYBER_K * KYBER_POLYBYTES;
const int KYBER_POLYVECCOMPRESSEDBYTES = KYBER_K * KYBER_POLYCOMPRESSEDBYTES;

// Tamaños específicos del IND-CPA KEM interno
const int KYBER_INDCPA_PUBLICKEYBYTES = KYBER_POLYVECCOMPRESSEDBYTES + KYBER_SYMBYTES;
const int KYBER_INDCPA_SECRETKEYBYTES = KYBER_POLYVECBYTES;
const int KYBER_INDCPA_BYTES = KYBER_POLYVECCOMPRESSEDBYTES + KYBER_POLYCOMPRESSEDBYTES;

// Bits de compresión utilizados en la codificación de u y v en el ciphertext
const int KYBER_DU = 10;
const int KYBER_DV = 4;

// Todos estos parámetros siguen la documentación oficial de Kyber.
