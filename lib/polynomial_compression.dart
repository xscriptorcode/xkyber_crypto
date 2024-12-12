// polynomial_compression.dart
//
// Estas funciones permiten comprimir y descomprimir coeficientes polinomiales
// mapeando el intervalo [0, q) a [0, 2^d) y viceversa, lo que se usa en Kyber
// para reducir el tamaño de la clave pública y el ciphertext.
//
// - compressCoefficient: Mapea x en [0,q) a un entero en [0, 2^d) aproximadamente.
// - decompressCoefficient: Realiza la operación inversa aproximada.
//
// La compresión es una parte esencial de Kyber para reducir el tamaño de
// la información transmitida. Por ejemplo, la parte "u" del ciphertext
// se comprime con d=10 bits, y la parte "v" con d=4 bits en Kyber512.

/// Comprime un coeficiente de polinomio [x] a [d] bits de precisión, según módulo [q].
/// Se calcula: floor(x * 2^d / q) mod 2^d
int compressCoefficient(int x, int d, int q) {
  return ((x * (1 << d)) ~/ q) % (1 << d);
}

/// Descomprime un coeficiente [x] desde [d] bits a su valor aproximado original en [0,q).
/// Se calcula: floor(x * q / 2^d)
int decompressCoefficient(int x, int d, int q) {
  return ((x * q) ~/ (1 << d));
}

/// Aplica compresión a todos los coeficientes de un polinomio.
List<int> compressPolynomial(List<int> polynomial, int d, int q) {
  return polynomial.map((coeff) => compressCoefficient(coeff, d, q)).toList();
}

/// Aplica descompresión a todos los coeficientes de un polinomio comprimido.
List<int> decompressPolynomial(List<int> compressedPolynomial, int d, int q) {
  return compressedPolynomial
      .map((coeff) => decompressCoefficient(coeff, d, q))
      .toList();
}
