// example/main.dart as general

// ignore_for_file: always_specify_types

// ignore: unused_import
import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart'; // Adjust the path as necessary

void main() {
  group('Random Bytes', () {
    test('randombytes returns the correct number of bytes', () {
      final bytes = randombytes(16);
      expect(bytes.length, equals(16));
    });
  });

  group('SHAKE128', () {
    test('Generates output of the requested length', () {
      final seed = Uint8List.fromList(List.generate(10, (i) => i));
      final out = shake128(seed, 64);
      expect(out.length, equals(64));
    });
  });

  group('Polynomial Operations', () {
    test('Serialization/Deserialization of a polynomial', () {
      final poly = Poly();
      // Initialize polynomial coefficients with test values.
      for (int i = 0; i < KYBER_N; i++) {
        poly.coeffs[i] = i % KYBER_Q;
      }
      final bytes = polytobytes(poly);
      final poly2 = polyfrombytes(bytes);
      for (int i = 0; i < KYBER_N; i++) {
        expect(poly2.coeffs[i] % KYBER_Q, equals(poly.coeffs[i] % KYBER_Q),
            reason: 'Coefficient $i does not match');
      }
    });

    test('Compression/Decompression of a polynomial', () {
      final poly = Poly();
      // Use a test polynomial; here we use (i * 7) mod KYBER_Q.
      for (int i = 0; i < KYBER_N; i++) {
        poly.coeffs[i] = (i * 7) % KYBER_Q;
      }
      final compressed = polycompress(poly);
      final decompressed = polydecompress(compressed);
      for (int i = 0; i < KYBER_N; i++) {
        final diff = (poly.coeffs[i] - decompressed.coeffs[i]).abs();
        // Increase the tolerance to 209 due to quantization error from 3-bit compression.
        expect(diff, lessThan(209),
            reason: 'Coefficient $i: difference $diff exceeds tolerance');
      }
    });
  });

  group('PolyVec Operations', () {
    test('Serialization/Deserialization of PolyVec', () {
      final polyVec = PolyVec();
      // Set each polynomial in the vector with test values.
      for (int i = 0; i < KYBER_K; i++) {
        for (int j = 0; j < KYBER_N; j++) {
          polyVec.vec[i].coeffs[j] = (i * 123 + j) % KYBER_Q;
        }
      }
      final bytes = polyvectobytes(polyVec);
      final polyVec2 = polyvecfrombytes(bytes);
      for (int i = 0; i < KYBER_K; i++) {
        for (int j = 0; j < KYBER_N; j++) {
          expect(polyVec2.vec[i].coeffs[j] % KYBER_Q,
              equals(polyVec.vec[i].coeffs[j] % KYBER_Q),
              reason: 'PolyVec[$i] coefficient $j does not match');
        }
      }
    });
  });

  group('IND-CPA and KEM', () {
    test('Keypair, encapsulation, and decapsulation', () {
      // Generate keypair.
      final keypair = KyberKeyPair.generate();
      expect(keypair.publicKey.length, equals(KYBER_PUBLICKEYBYTES));
      expect(keypair.secretKey.length, equals(KYBER_SECRETKEYBYTES));

      // Encapsulate using the public key.
      final encapsulationResult = KyberKEM.encapsulate(keypair.publicKey);
      final ciphertext = encapsulationResult.ciphertextKEM;
      final sharedSecretEnc = encapsulationResult.sharedSecret;

      // Decapsulate using the secret key.
      final sharedSecretDec = KyberKEM.decapsulate(ciphertext, keypair.secretKey);

      // The shared secrets should match.
      expect(sharedSecretDec, equals(sharedSecretEnc));
    });
  });

  group('Symmetric Encryption (AES-GCM)', () {
    test('Symmetric encryption and decryption', () async {
      final key = await XKyberCrypto.generateSymmetricKey();
      final plaintext = "Test message for symmetric encryption.";
      final encrypted = await XKyberCrypto.symmetricEncrypt(plaintext, key);
      final decrypted = await XKyberCrypto.symmetricDecrypt(encrypted, key);
      expect(decrypted, equals(plaintext));
    });
  });

  group('Constant Time Comparison', () {
    test('constantTimeCompare works correctly', () {
      final a = Uint8List.fromList([1, 2, 3, 4, 5]);
      final b = Uint8List.fromList([1, 2, 3, 4, 5]);
      final c = Uint8List.fromList([1, 2, 3, 4, 6]);
      expect(constantTimeCompare(a, b), isTrue);
      expect(constantTimeCompare(a, c), isFalse);
    });
  });
}
