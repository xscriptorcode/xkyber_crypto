// lib/crypto/polynomial_compression.dart

/// Comprime un coeficiente de polinomio a un tamaño específico utilizando un módulo.
int compressCoefficient(int x, int d, int q) {
  return ((x * (1 << d)) ~/ q) % (1 << d);
}

/// Descomprime un coeficiente de polinomio comprimido al valor original aproximado.
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
