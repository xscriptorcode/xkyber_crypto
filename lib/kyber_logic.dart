// kyber_logic.dart
//
// Estas funciones NO forman parte del esquema Kyber estándar.
// Kyber genera una clave compartida (ss) tras encapsulación/descapsulación del KEM.
// Usar esa clave compartida (ss) con un cifrador simétrico (ej: AES-GCM) sería la forma recomendada.
//
// El código aquí mostrado usa polinomios y aritmética modular para "encriptar" en un esquema ad-hoc,
// no es el flujo real de Kyber. Se deja como ejemplo demostrativo.
//
// Si se desea la lógica real, ignorar este archivo y usar crypto_kem_{keypair,enc,dec} del KEM.

import 'package:xkyber_crypto/polynomial.dart';
import 'package:xkyber_crypto/modular_arithmetic.dart';
import 'package:xkyber_crypto/kyber_keypair.dart';

/// Crea una clave compartida a partir de un par de llaves y otra llave pública.
// Nota: Esto no sigue la lógica real de Kyber.
// Kyber real usa crypto_kem_enc/dec para obtener la sharedSecret en bytes.
Polynomial createSharedKey(KyberKeyPair keyPair, Polynomial otherPublicKey, int mod) {
  // En la lógica actual: asume que keyPair tiene polinomios (ya no los tiene).
  // Podrías reconstruir un polinomio dummy o sencillamente dejar un placeholder.
  // Dado que KyberKeyPair ahora retorna bytes, esto no es realista.
  //
  // Ejemplo: Crear polinomios fijos, esto es solo un ejemplo.
  Polynomial priv = Polynomial(List.filled(256, 1));
  return priv.multiply(otherPublicKey, mod);
}

/// Cifra datos con una clave compartida polinómica (ejemplo inventado, no Kyber)
String encryptSession(String sessionData, Polynomial sharedKey, int mod) {
  List<int> dataBytes = sessionData.codeUnits;
  List<int> encryptedBytes = [];

  for (int i = 0; i < dataBytes.length; i++) {
    int sharedKeyCoeff = sharedKey.coefficients[i % sharedKey.coefficients.length];
    if (sharedKeyCoeff == 0 || gcd(sharedKeyCoeff, mod) != 1) {
      throw Exception("Coeficiente no invertible en la clave compartida.");
    }
    int encryptedByte = modMul(dataBytes[i], sharedKeyCoeff, mod);
    encryptedBytes.add(encryptedByte);
  }

  return encryptedBytes.join('-');
}

/// Descifra datos con la clave compartida polinómica (ejemplo inventado)
String decryptSession(String encryptedData, Polynomial sharedKey, int mod) {
  List<int> encryptedBytes = encryptedData.split('-').map(int.parse).toList();
  List<int> decryptedBytes = [];

  for (int i = 0; i < encryptedBytes.length; i++) {
    int sharedKeyCoeff = sharedKey.coefficients[i % sharedKey.coefficients.length];
    if (sharedKeyCoeff == 0 || gcd(sharedKeyCoeff, mod) != 1) {
      throw Exception("Coeficiente no invertible en la clave compartida.");
    }
    int invSharedKeyCoeff = modInverse(sharedKeyCoeff, mod);
    int decryptedByte = modMul(encryptedBytes[i], invSharedKeyCoeff, mod);
    decryptedBytes.add(decryptedByte);
  }

  return String.fromCharCodes(decryptedBytes);
}

/// gcd (útil para verificar invertibilidad)
int gcd(int a, int b) {
  while (b != 0) {
    int temp = b;
    b = a % b;
    a = temp;
  }
  return a;
}
