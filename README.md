# xKyberCrypto

**xKyberCrypto** is a library for post-quantum encryption in Dart, based on the Kyber algorithm. It is designed for applications requiring high standards of cryptographic security, especially in the context of Flutter.

The Kyber algorithm is part of the proposals selected by NIST for post-quantum cryptography standards, designed to withstand attacks from quantum computers.

## Features

- Generation of public and private key pairs using the Kyber algorithm.
- Message encryption using a public key to produce a shared key.
- Decryption of encrypted messages using a private key to recover the shared key.
- Secure deterministic noise generation using AES in CTR mode.
- Compatible with the latest versions of Dart and its tools.

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
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  final xkyber = XKyberCryptoBase();

  // Generate public and private keys
  final keyPair = xkyber.generateKeyPair();
  print('Public Key: ${keyPair.publicKey}');
  print('Private Key: ${keyPair.privateKey}');

  // Encrypt a message
  final message = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
  final ciphertext = xkyber.encrypt(message, keyPair.publicKey.coefficients);
  print('Encrypted Message: $ciphertext');

  // Decrypt the message
  final decryptedMessage = xkyber.decrypt(ciphertext, keyPair.privateKey.coefficients);
  print('Decrypted Message: $decryptedMessage');

  // Generate deterministic noise
  final seed = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7]);
  final noise = xkyber.generateNoise(seed);
  print('Deterministic Noise: $noise');
}
```

This example covers:

- Generating public and private keys.
- Encrypting and decrypting messages.
- Using deterministic noise for secure operations.

---

## API

### Main Classes

- **`XKyberCryptoBase`**:
  - `generateKeyPair()`: Generates a pair of keys (public and private).
  - `encrypt(Uint8List message, Uint8List publicKey)`: Encrypts a message using the public key.
  - `decrypt(List<int> ciphertext, Uint8List privateKey)`: Decrypts an encrypted message using the private key.
  - `generateNoise(Uint8List seed)`: Generates deterministic noise from a seed.

---

## Project Structure

- **`lib/`**:
  Contains the main implementation of the library.
  - `kyber_kem.dart`: Implementation of the Kyber Key Encapsulation Mechanism.
  - `modular_arithmetic.dart`: Mathematical utilities for modular operations.
  - `polynomial.dart`: Representation and manipulation of polynomials.
  - `deterministic_noise_generator.dart`: Deterministic noise generation.

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

This library includes a comprehensive set of automated tests to ensure the functionality of its core features, such as:

- **Shared Key Generation**: Verifies the creation of a shared key from public and private keys.
- **Encryption and Decryption**: Tests the correctness of message encryption and decryption processes.
- **Error Handling**: Ensures that invalid inputs throw the expected exceptions.
- **Mathematical Operations**: Validates core modular arithmetic functions, like `gcd` (Greatest Common Divisor).

The tests are located in the `test/` folder and can be executed using the following command:

```bash
dart test
```

---

## Warnings and Limitations

- This library is intended for research and learning purposes; it is not recommended for production environments without additional audits.
- Performance on low-power devices may vary depending on the size of the encrypted data.

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
