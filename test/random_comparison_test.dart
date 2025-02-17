// random_comparison_test.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  group('Random Generation Comparison Test', () {
    test('Two independent key generations produce different keys and shared secrets', () {
      // Genera el primer par de claves.
      KyberKeyPair keyPair1 = KyberKeyPair.generate();
      // Genera el segundo par de claves.
      KyberKeyPair keyPair2 = KyberKeyPair.generate();

      // Se espera que las claves sean distintas.
      expect(keyPair1.publicKey, isNot(equals(keyPair2.publicKey)),
          reason: 'Two independently generated public keys should differ.');
      expect(keyPair1.secretKey, isNot(equals(keyPair2.secretKey)),
          reason: 'Two independently generated secret keys should differ.');

      // Realiza encapsulación con cada clave pública.
      KyberEncapsulationResult enc1 = KyberKEM.encapsulate(keyPair1.publicKey);
      KyberEncapsulationResult enc2 = KyberKEM.encapsulate(keyPair2.publicKey);

      // Se espera que los secretos compartidos sean distintos.
      expect(enc1.sharedSecret, isNot(equals(enc2.sharedSecret)),
          reason: 'Two encapsulated shared secrets should differ.');

      // Comprobación extra: encapsular dos veces con la misma clave pública debe dar el mismo secreto compartido.
      KyberEncapsulationResult enc1_repeat = KyberKEM.encapsulate(keyPair1.publicKey);
      expect(enc1.sharedSecret, equals(enc1_repeat.sharedSecret),
          reason: 'Encapsulating twice with the same public key should produce the same shared secret.');

      // Imprime resultados en Base64 para verificación manual.
      print('Key Pair 1 Public Key (Base64): ${base64Encode(keyPair1.publicKey)}');
      print('Key Pair 2 Public Key (Base64): ${base64Encode(keyPair2.publicKey)}');
      print('Key Pair 1 Secret Key (Base64): ${base64Encode(keyPair1.secretKey)}');
      print('Key Pair 2 Secret Key (Base64): ${base64Encode(keyPair2.secretKey)}');
      print('Key Pair 1 Shared Secret (Base64): ${base64Encode(enc1.sharedSecret)}');
      print('Key Pair 2 Shared Secret (Base64): ${base64Encode(enc2.sharedSecret)}');
    });
  });
}
