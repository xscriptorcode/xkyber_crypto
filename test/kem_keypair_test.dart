// kem_keypair_test.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';
import 'package:xkyber_crypto/params.dart';

void main() {
  group('Kyber KEM Key Generation and Encapsulation/Decapsulation', () {
    test('Key pair generation produces correct key sizes and matching shared secret', () {
      // Genera la clave pública y la clave privada.
      Uint8List pk = Uint8List(KYBER_PUBLICKEYBYTES);
      Uint8List sk = Uint8List(KYBER_SECRETKEYBYTES);
      int ret = cryptokemkeypair(pk, sk);
      expect(ret, equals(0), reason: 'Key pair generation failed.');

      // Verifica que las longitudes sean las esperadas.
      expect(pk.length, equals(KYBER_PUBLICKEYBYTES),
          reason: 'Public key length is not as expected.');
      expect(sk.length, equals(KYBER_SECRETKEYBYTES),
          reason: 'Secret key length is not as expected.');

      // Comprueba que las claves tengan contenido (no sean todas ceros).
      int pkNonZero = pk.where((b) => b != 0).length;
      int skNonZero = sk.where((b) => b != 0).length;
      expect(pkNonZero, greaterThan(0), reason: 'Public key is all zeros.');
      expect(skNonZero, greaterThan(0), reason: 'Secret key is all zeros.');

      // Encapsulación: genera ciphertext y shared secret usando la clave pública.
      Uint8List ciphertext = Uint8List(KYBER_CIPHERTEXTBYTES);
      Uint8List ssEnc = Uint8List(KYBER_SSBYTES);
      ret = cryptokemenc(ciphertext, ssEnc, pk);
      expect(ret, equals(0), reason: 'Encapsulation failed.');

      // Decapsulación: recupera el shared secret usando la clave privada.
      Uint8List ssDec = Uint8List(KYBER_SSBYTES);
      ret = cryptokemdec(ssDec, ciphertext, sk);
      expect(ret, equals(0), reason: 'Decapsulation failed.');

      // Verifica que el shared secret encapsulado y el decapsulado sean iguales.
      expect(ssDec, equals(ssEnc), reason: 'Shared secrets do not match.');

      // Imprime los resultados para inspección.
      print('\n--- Kyber KEM Test Results ---');
      print('Public Key (Base64): ${base64Encode(pk)}');
      print('Secret Key (Base64): ${base64Encode(sk)}');
      print('Ciphertext (Base64): ${base64Encode(ciphertext)}');
      print('Shared Secret (Encapsulated, Base64): ${base64Encode(ssEnc)}');
      print('Shared Secret (Decapsulated, Base64): ${base64Encode(ssDec)}');
    });
  });
}
