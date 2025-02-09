# XKyber_crypto

Is a Dart library for post-quantum encryption, providing a Key Encapsulation Mechanism (KEM) based on the Kyber algorithm. Kyber is a post-quantum cryptographic scheme selected by NIST for standardization, designed to be secure against attacks from quantum computers.

## Features

- Generation of public and private key pairs using the Kyber KEM.
- Encapsulation of a shared secret using a public key.
- Decapsulation of the shared secret using a private key.
- The shared secret can then be used with a symmetric cipher (e.g., AES-GCM) to encrypt or decrypt arbitrary messages.
- Uses SHAKE128 and fully follows the official Kyber specifications.

---

## Prerequisites

Before using this library, ensure you have the following:
- Dart SDK: version 2.12.0 or higher.
- Flutter (optional, if using this library in a Flutter project).
- An editor such as Visual Studio Code or IntelliJ to facilitate development.

---

## Installation

To install this library, add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  xkyber_crypto:
    git:
      url: https://github.com/xscriptorcode/xkyber_crypto.git
```

Update your dependencies with:

```bash
dart pub get
```

---

## Usage Example

- Here’s a basic example of how to use this library:

```dart
// example/general_example.dart
// ignore_for_file: avoid_print, always_specify_types

import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';

Future<void> main() async {
  print("=== XKyber_crypto Usage Example ===");

  // 1. Key Pair Generation
  // Generate a Kyber key pair.
  KyberKeyPair keypair = KyberKeyPair.generate();
  print("Public Key (${keypair.publicKey.length} bytes):");
  print(keypair.publicKey);
  print("Secret Key (${keypair.secretKey.length} bytes):");
  print(keypair.secretKey);

  // 2. Encapsulation
  // Using the public key, encapsulate a shared secret.
  KyberEncapsulationResult encapsulationResult = KyberKEM.encapsulate(keypair.publicKey);
  Uint8List ciphertext = encapsulationResult.ciphertextKEM;
  Uint8List sharedSecretEnc = encapsulationResult.sharedSecret;
  print("\nCiphertext (${ciphertext.length} bytes):");
  print(ciphertext);
  print("\nEncapsulated Shared Secret (${sharedSecretEnc.length} bytes):");
  print(sharedSecretEnc);

  // 3. Decapsulation
  // Using the secret key, decapsulate to recover the shared secret.
  Uint8List sharedSecretDec = KyberKEM.decapsulate(ciphertext, keypair.secretKey);
  print("\nDecapsulated Shared Secret (${sharedSecretDec.length} bytes):");
  print(sharedSecretDec);

  // 4. Verify that both shared secrets match.
  if (sharedSecretEnc.toString() == sharedSecretDec.toString()) {
    print("\nShared secrets match!");
  } else {
    print("\nShared secrets do NOT match!");
  }

  // 5. (Optional) Symmetric Encryption using the Shared Secret
  // Here, we demonstrate how to generate a symmetric key, encrypt a message,
  // and then decrypt it using the AES-GCM implementation provided in xkyber_symmetric.dart.
  Uint8List symKey = await XKyberCrypto.generateSymmetricKey();
  String plaintext = "This is a secret message.";
  String encrypted = await XKyberCrypto.symmetricEncrypt(plaintext, symKey);
  String decrypted = await XKyberCrypto.symmetricDecrypt(encrypted, symKey);

  print("\nSymmetric Encryption Example:");
  print("Plaintext: $plaintext");
  print("Encrypted (Base64): $encrypted");
  print("Decrypted: $decrypted");
}

```
- Here is how you can test the library:

```dart
// /example/main.dart == example file
// ignore_for_file: avoid_print, always_specify_types

// test/general_test.dart

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
        // Increase the tolerance to 50 due to quantization error from 3-bit compression.
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



```

## This example demonstrates:

- Generating a Kyber key pair.
- Encapsulating a shared secret with cryptoKemEnc and pk.
- Decapsulating the shared secret with cryptoKemDec and sk.
- Using the shared secret (ss) for symmetric encryption.

---

# API


## Main Functions
- cryptoKemKeypair(Uint8List pk, Uint8List sk): Generates a Kyber key pair.
- cryptoKemEnc(Uint8List c, Uint8List ss, Uint8List pk): Encapsulates a shared secret ss using pk and produces ciphertext c.
- cryptoKemDec(Uint8List ss, Uint8List c, Uint8List sk): Decapsulates c using sk to recover ss.

## Classes
- KyberKeyPair:
- generate(): Produces a Kyber key pair (publicKey, privateKey).
- publicKey, privateKey: Byte arrays representing the keys.

---

## Project Structure

- **`lib/`**:
  Contains the main implementation of the library.
- kem.dart: Core Kyber KEM functions (cryptoKemEnc, cryptoKemDec, cryptoKemKeypair).
- kyber_keypair.dart: Handles key generation and utilities.
- poly.dart, polyvec.dart, ntt.dart, params.dart, etc.: Core Kyber implementation (NTT, polynomial operations, parameter definitions).
- shake.dart: SHAKE128 implementation.
- reduce.dart, fq.dart: Modular arithmetic and field operations.

- **`example/`**:
  Example code for understanding the library usage.

- **`test/`**:
  Automated tests to verify library functionality.

---

## Dependencies

The library uses the following dependencies:

- **`crypto: ^3.0.6`**: Provides common cryptographic functions.
- **`pointycastle: ^3.9.1`**: Advanced library for cryptography in Dart.
- **`lints: ^5.0.0`**: Establishes style rules and best practices for Dart code.

Ensure you have the latest versions to guarantee compatibility and performance.

---

## Testing and Quality

### Automated Tests

### The library includes tests to verify:

- Key Generation and Shared Secret: Ensures correctness of generated keys and shared secrets.
- Encapsulation/Decapsulation: Validates that cryptoKemEnc and cryptoKemDec produce matching shared secrets.
- Math Operations: Checks NTT, modular arithmetic, and noise distribution.

Run with:

```bash
dart test
```

---

## Warnings and Limitations

- The library is intended for research, testing, and educational use. For production environments, a thorough security audit is recommended.
- Performance may vary depending on device capabilities.

---

## Contributions

Contributions are welcome. To contribute:

1. Fork this repository.
2. Create a new branch (`git checkout -b feature/new-functionality`).
3. Make your changes and commit them (`git commit -m 'Add new functionality'`).
4. Push your branch (`git push origin feature/new-functionality`).
5. Open a Pull Request in this repository.

---

## Acknowledgments and References

This project is inspired by the Kyber algorithm, selected by NIST as part of its post-quantum cryptography standards. More information about Kyber is available [here](https://pq-crystals.org/kyber/).

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
