// indcpa_publickey_full_test.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';
import 'package:xkyber_crypto/params.dart';

void main() {
  group('IND-CPA Public Key Tests', () {
    test('Generated IND-CPA public key has correct size (288 bytes for Kyber512 IND-CPA) and prints content naturally', () {
      // Asigna buffers para la clave pública IND-CPA y la clave secreta.
      Uint8List pk = Uint8List(KYBER_INDCPA_PUBLICKEYBYTES); // 288 bytes
      Uint8List sk = Uint8List(KYBER_INDCPA_SECRETKEYBYTES);

      // Genera el par de claves IND-CPA.
      indcpakeypair(pk, sk);

      // Verifica que la longitud total de la clave pública sea 288 bytes.
      expect(pk.length, equals(KYBER_INDCPA_PUBLICKEYBYTES),
          reason: 'Public key length is not as expected.');

      // Separa las dos partes de la clave pública:
      // 1. La parte del polyvec comprimido (primeros KYBER_POLYVECCOMPRESSEDBYTES bytes).
      // 2. La semilla pública (últimos KYBER_SYMBYTES bytes).
      Uint8List polyvecPart = pk.sublist(0, KYBER_POLYVECCOMPRESSEDBYTES); // 256 bytes
      Uint8List seedPart = pk.sublist(KYBER_POLYVECCOMPRESSEDBYTES, KYBER_INDCPA_PUBLICKEYBYTES); // 32 bytes

      // Calcula la distribución de ceros en la parte comprimida.
      int zeroCount = polyvecPart.where((b) => b == 0).length;
      int nonZeroCount = polyvecPart.length - zeroCount;
      double ratioZeros = zeroCount / polyvecPart.length;
      double ratioNonZeros = nonZeroCount / polyvecPart.length;

      // Imprime la clave en distintos formatos.
      print('--- IND-CPA Public Key ---');
      print('Total Length: ${pk.length} bytes');

      print('\nPolyvec Compressed Portion (256 bytes):');
      print('Zero count: $zeroCount, Non-zero count: $nonZeroCount');
      print('Zero ratio: ${ratioZeros.toStringAsFixed(2)}, Non-zero ratio: ${ratioNonZeros.toStringAsFixed(2)}');
      
      print('\nPolyvec Compressed (hex):');
      print(polyvecPart.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));
      
      print('\nPolyvec Compressed (decimal list):');
      print(polyvecPart);
      
      print('\nPublic Seed (32 bytes, hex):');
      print(seedPart.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));
      
      print('\nFull IND-CPA Public Key (Base64):');
      print(base64Encode(pk));

      // Aserciones sobre contenido:
      expect(zeroCount, lessThan(polyvecPart.length),
          reason: 'The polyvec portion is all zeros.');
      expect(nonZeroCount, greaterThan(0),
          reason: 'The polyvec portion has no zeros.');
      expect(seedPart.where((b) => b != 0).length, greaterThan(0),
          reason: 'The public seed portion is all zeros.');
      // Opcional: se espera que la proporción de ceros esté en un rango razonable (por ejemplo, entre 10% y 90%).
      expect(ratioZeros, inInclusiveRange(0.1, 0.9),
          reason: 'The zero ratio ($ratioZeros) is out of the expected range (10%-90%).');
    });
  });
}
