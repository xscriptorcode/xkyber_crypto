// kem_full_test.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  group('Kyber KEM Full Test (IND-CCA2)', () {
    test(
        'Key generation, public key distribution, and encapsulation/decapsulation',
        () {
      // Para IND-CCA2, según la especificación de Kyber512:
      // - Public key (pk) debe tener KYBER_PUBLICKEYBYTES (800 bytes)
      // - Secret key (sk) debe tener KYBER_SECRETKEYBYTES (1632 bytes)
      Uint8List pk = Uint8List(KYBER_PUBLICKEYBYTES); // 800 bytes
      Uint8List sk = Uint8List(KYBER_SECRETKEYBYTES); // 1632 bytes

      // Genera el par de claves IND-CCA2.
      int retKeypair = cryptokemkeypair(pk, sk);
      expect(retKeypair, equals(0), reason: 'Key pair generation failed.');

      // Imprime la clave pública IND-CCA2 en Base64.
      print('\n--- IND-CCA2 Public Key (Base64) ---');
      print(base64Encode(pk));

      // Si deseas ver la parte IND-CPA (comprimida) que se almacena en la pk,
      // ésta se encuentra en los primeros KYBER_POLYVECCOMPRESSEDBYTES bytes.
      // ignore: unused_local_variable
      Uint8List indcpaPart = pk.sublist(
          0, KYBER_POLYVECCOMPRESSEDBYTES); // Debe ser 256 bytes (2*128)
      Uint8List seedPart = pk.sublist(KYBER_POLYVECCOMPRESSEDBYTES,
          KYBER_INDCPA_PUBLICKEYBYTES); // 32 bytes

      // Aunque en la pk IND-CCA2 el tamaño total es 800 bytes,
      // la porción IND-CPA (de 288 bytes) se encuentra almacenada dentro de ella.
      // Para efectos de análisis, podemos revisar la porción comprimida IND-CPA:
      print('\n--- IND-CPA Public Key Portion (within sk) ---');
      // La pk IND-CPA se almacena en sk en los últimos KYBER_PUBLICKEYBYTES + KYBER_SYMBYTES bytes, o en otra ubicación.
      // En esta implementación, la pk IND-CPA se copia directamente en pk (de tamaño 288 bytes).
      // Como ya usamos cryptokemkeypair, la pk IND-CCA2 contiene la pk IND-CPA en sus primeros 288 bytes.
      Uint8List indcpaPublicKey = pk.sublist(0, KYBER_INDCPA_PUBLICKEYBYTES);
      print('IND-CPA Public Key (Base64):');
      print(base64Encode(indcpaPublicKey));

      // Analiza la distribución en la parte comprimida del IND-CPA pk:
      Uint8List polyvecCompressed =
          indcpaPublicKey.sublist(0, KYBER_POLYVECCOMPRESSEDBYTES); // 256 bytes
      int zeroCount = polyvecCompressed.where((b) => b == 0).length;
      int nonZeroCount = polyvecCompressed.length - zeroCount;
      double ratioZeros = zeroCount / polyvecCompressed.length;
      double ratioNonZeros = nonZeroCount / polyvecCompressed.length;

      print('\n--- IND-CPA Polyvec Compressed Portion (256 bytes) ---');
      print('Zero count: $zeroCount, Non-zero count: $nonZeroCount');
      print(
          'Zero ratio: ${ratioZeros.toStringAsFixed(2)}, Non-zero ratio: ${ratioNonZeros.toStringAsFixed(2)}');
      print('\nPolyvec Compressed (hex):');
      print(polyvecCompressed
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' '));
      print('\nPolyvec Compressed (decimal list):');
      print(polyvecCompressed);

      print('\nPublic Seed (32 bytes, hex):');
      print(seedPart.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));

      // Aserciones: verifica que la parte comprimida no sea completamente cero ni completamente no cero.
      expect(zeroCount, lessThan(polyvecCompressed.length),
          reason: 'The polyvec portion is completely zero.');
      expect(nonZeroCount, greaterThan(0),
          reason: 'The polyvec portion has no zeros.');
      // Opcional: verifica que la proporción de ceros esté en un rango razonable (por ejemplo, entre 10% y 90%).
      expect(ratioZeros, inInclusiveRange(0.1, 0.9),
          reason:
              'Zero ratio ($ratioZeros) is outside the expected range (10%-90%).');

      // --- Encapsulación/Decapsulación ---
      Uint8List ciphertext = Uint8List(KYBER_CIPHERTEXTBYTES);
      Uint8List ssEnc = Uint8List(KYBER_SSBYTES);
      int retEnc = cryptokemenc(ciphertext, ssEnc, pk);
      expect(retEnc, equals(0), reason: 'Encapsulation failed.');

      Uint8List ssDec = Uint8List(KYBER_SSBYTES);
      int retDec = cryptokemdec(ssDec, ciphertext, sk);
      expect(retDec, equals(0), reason: 'Decapsulation failed.');

      // Verifica que el secreto compartido encapsulado y el decapsulado sean iguales.
      expect(ssDec, equals(ssEnc), reason: 'Shared secrets do not match.');

      print('\n--- Shared Secrets (Base64) ---');
      print('Encapsulated: ${base64Encode(ssEnc)}');
      print('Decapsulated: ${base64Encode(ssDec)}');
    });
  });
}
