// lib/crypto/kyber_logic.dart

import 'package:xkyber_crypto/polynomial.dart';
import 'package:xkyber_crypto/modular_arithmetic.dart';
import 'package:xkyber_crypto/kyber_keypair.dart';

/// Función para crear una clave compartida a partir de un par de claves y otra clave pública
Polynomial createSharedKey(
    KyberKeyPair keyPair, Polynomial otherPublicKey, int mod) {
  return keyPair.privateKey.multiply(otherPublicKey, mod);
}

/// Cifra los datos de sesión usando la clave compartida
String encryptSession(String sessionData, Polynomial sharedKey, int mod) {
  List<int> dataBytes = sessionData.codeUnits;
  List<int> encryptedBytes = [];

  for (int i = 0; i < dataBytes.length; i++) {
    int sharedKeyCoeff =
        sharedKey.coefficients[i % sharedKey.coefficients.length];
    if (sharedKeyCoeff == 0 || gcd(sharedKeyCoeff, mod) != 1) {
      throw Exception("Coeficiente no invertible en la clave compartida.");
    }
    int encryptedByte = modMul(dataBytes[i], sharedKeyCoeff, mod);
    encryptedBytes.add(encryptedByte);
  }

  return encryptedBytes.join('-'); // Convertir a una cadena
}

/// Descifra los datos de sesión usando la clave compartida
String decryptSession(String encryptedData, Polynomial sharedKey, int mod) {
  List<int> encryptedBytes = encryptedData.split('-').map(int.parse).toList();
  List<int> decryptedBytes = [];

  for (int i = 0; i < encryptedBytes.length; i++) {
    int sharedKeyCoeff =
        sharedKey.coefficients[i % sharedKey.coefficients.length];
    if (sharedKeyCoeff == 0 || gcd(sharedKeyCoeff, mod) != 1) {
      throw Exception("Coeficiente no invertible en la clave compartida.");
    }
    int invSharedKeyCoeff = modInverse(sharedKeyCoeff, mod);
    int decryptedByte = modMul(encryptedBytes[i], invSharedKeyCoeff, mod);
    decryptedBytes.add(decryptedByte);
  }

  return String.fromCharCodes(decryptedBytes);
}

/// Calcula el máximo común divisor utilizando el algoritmo de Euclides
int gcd(int a, int b) {
  while (b != 0) {
    int temp = b;
    b = a % b;
    a = temp;
  }
  return a;
}
