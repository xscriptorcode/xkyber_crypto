// lib/utils/coefficients_codec.dart

import 'dart:convert';
import 'dart:typed_data';

/// Codifica una lista de coeficientes en una cadena Base64 utilizando 2 bytes por coeficiente (big-endian).
String encodeCoefficients(List<int> coefficients) {
  final bytes = <int>[];
  for (var coeff in coefficients) {
    if (coeff < 1 || coeff >= 3329) {
      throw ArgumentError('Coeficiente fuera del rango permitido: $coeff');
    }
    bytes.add((coeff >> 8) & 0xFF); // Byte alto
    bytes.add(coeff & 0xFF);        // Byte bajo
  }
  return base64Encode(Uint8List.fromList(bytes));
}

/// Decodifica una cadena Base64 a una lista de coeficientes, asumiendo 2 bytes por coeficiente (big-endian).
List<int> decodeCoefficients(String base64Str) {
  final bytes = base64Decode(base64Str);
  if (bytes.length % 2 != 0) {
    throw FormatException("Longitud de bytes inválida para decodificar coeficientes.");
  }
  List<int> coefficients = [];
  for (int i = 0; i < bytes.length; i += 2) {
    int coeff = (bytes[i] << 8) | bytes[i + 1];
    if (coeff == 0 || coeff >= 3329) {
      throw FormatException("Coeficiente fuera del rango permitido: $coeff.");
    }
    coefficients.add(coeff);
  }
  return coefficients;
}
