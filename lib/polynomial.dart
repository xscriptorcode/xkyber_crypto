import 'ntt.dart';

/// polynomial.dart
///
/// Ahora integramos la NTT en la multiplicación de polinomios.
/// En Kyber, la multiplicación de dos polinomios se realiza:
/// 1. Convertir ambos polinomios al dominio NTT.
/// 2. Multiplicación punto a punto.
/// 3. Aplicar iNTT para volver al dominio original.
/// 
/// Aquí asumimos que ya tenemos las funciones ntt() e intt() implementadas en ntt.dart.
/// Esta lógica sigue siendo simplificada respecto a Kyber completo.

class Polynomial {
  List<int> coefficients;

  Polynomial(this.coefficients);

  factory Polynomial.fixed() {
    // Para Kyber: n=256
    return Polynomial(List<int>.filled(256, 1));
  }

  Polynomial add(Polynomial other, int mod) {
    int length = coefficients.length;
    List<int> result = List.filled(length, 0);
    for (int i = 0; i < length; i++) {
      result[i] = (coefficients[i] + other.coefficients[i]) % mod;
    }
    return Polynomial(result);
  }

  /// Multiplicación de polinomios usando NTT.
  /// 
  /// PASOS (simplificados):
  /// - Aplicar NTT a ambos polinomios.
  /// - Multiplicación punto a punto.
  /// - Aplicar iNTT al resultado.
  /// - Resultado mod q.
  Polynomial multiply(Polynomial other, int mod) {
    // Clonar coeficientes
    List<int> a = List.from(coefficients);
    List<int> b = List.from(other.coefficients);

    // Convertir a dominio NTT
    a = ntt(a);
    b = ntt(b);

    // Multiplicación punto a punto en dominio NTT
    for (int i = 0; i < a.length; i++) {
      a[i] = (a[i] * b[i]) % mod;
    }

    // Volver al dominio original con iNTT
    a = invntt(a);

    // Resultado es el polinomio multiplicado
    return Polynomial(a);
  }

  factory Polynomial.fromList(List<int> list) {
    return Polynomial(List<int>.from(list));
  }
}
