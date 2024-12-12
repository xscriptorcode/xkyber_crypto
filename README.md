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

Here’s a basic example of how to use this library:

```dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:xkyber_crypto/kem.dart';
import 'package:xkyber_crypto/kyber_keypair.dart';

// Simple XOR-based encryption for demonstration only.
// In a real application, use a secure AEAD cipher like AES-GCM.
Uint8List xorEncrypt(Uint8List data, Uint8List key) {
  final result = Uint8List(data.length);
  for (int i = 0; i < data.length; i++) {
    result[i] = data[i] ^ key[i % key.length];
  }
  return result;
}

void main() {
  // Generate keypair (publicKey, privateKey)
  final keyPair = KyberKeyPair.generate();
  final pk = keyPair.publicKey;
  final sk = keyPair.privateKey;

  // Encapsulate a shared secret using the public key
  final c = Uint8List(768); // Kyber512 ciphertext size
  final ssSender = Uint8List(32); // Shared secret size: 32 bytes
  cryptoKemEnc(c, ssSender, pk);

  // On the receiver side, decapsulate using the private key to recover ss
  final ssReceiver = Uint8List(32);
  cryptoKemDec(ssReceiver, c, sk);

  // Both ssSender and ssReceiver are identical. Now use ss as a symmetric key.

  final message = utf8.encode("Hello, Kyber!") as Uint8List;
  
  // Encrypt message with ss (XOR for demonstration only)
  final ciphertext = xorEncrypt(message, ssSender);

  // Decrypt using ssReceiver
  final decrypted = xorEncrypt(ciphertext, ssReceiver);
  print("Decrypted message: ${utf8.decode(decrypted)}");
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
