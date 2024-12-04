// lib/crypto/polynomial.dart

class Polynomial {
  List<int> coefficients;

  Polynomial(this.coefficients);

  /// Método para crear un polinomio con valores fijos específicos.
  /// Este polinomio se usará en la generación de la clave pública en Kyber.
  factory Polynomial.fixed() {
    return Polynomial(List<int>.filled(256, 1)); // Todos los coeficientes =1
  }

  Polynomial add(Polynomial other, int mod) {
    int length = coefficients.length;
    List<int> result = List.filled(length, 0);
    for (int i = 0; i < length; i++) {
      result[i] = (coefficients[i] + other.coefficients[i]) % mod;
    }
    return Polynomial(result);
  }

  Polynomial multiply(Polynomial other, int mod) {
    int length = coefficients.length;
    List<int> result = List.filled(2 * length - 1, 0);
    for (int i = 0; i < length; i++) {
      for (int j = 0; j < other.coefficients.length; j++) {
        if (i + j < result.length) {
          result[i + j] =
              (result[i + j] + coefficients[i] * other.coefficients[j]) % mod;
        }
      }
    }
    // Reducir a la longitud original
    return Polynomial(result.sublist(0, length));
  }

  /// Método para crear un polinomio a partir de una lista, usado en fromJson
  factory Polynomial.fromList(List<int> list) {
    return Polynomial(List<int>.from(list));
  }
}
