# xKyberCrypto

**xKyberCrypto** is a library aimed at addressing post-quantum encryption in Flutter based on the Kyber algorithm, implemented in Dart. This library provides functionalities for key generation, encryption, and decryption, designed for applications requiring high cryptographic security.

## Features

- Generation of public and private key pairs using the Kyber algorithm.
- Message encryption using a public key to produce a shared key.
- Decryption of encrypted messages using a private key to recover the shared key.
- Generation of secure deterministic noise using AES in CTR mode.
## Installation

To install this library in your Dart project, add `xkyber_crypto` as a dependency in your `pubspec.yaml` file:
```yaml
dependencies:
  xkyber_crypto:
    git:
      url: https://github.com/xscriptorcode/xkyber_crypto.git
dart pub get
import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  final xkyber = XKyberCryptoBase();

  // Generate public and private keys
  final keyPair = xkyber.generateKeyPair();
  print('Public Key: ${keyPair.publicKey}');
  print('Private Key: ${keyPair.privateKey}');

  // example encrypting message
  final mensaje = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);

  // encrypt using the public key
  final ciphertext = xkyber.encrypt(mensaje, keyPair.publicKey.coefficients);
  print('Mensaje cifrado: $ciphertext');

  // decrypt using the private key
  final mensajeDescifrado = xkyber.decrypt(ciphertext, keyPair.privateKey.coefficients);
  print('Mensaje descifrado: $mensajeDescifrado');

  // Deterministic noise generation
  final seed = Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7]);
  final ruido = xkyber.generateNoise(seed);
  print('Ruido determinístico generado: $ruido');
}

This example demonstrates:

- How to generate a public and private key pair.
- How to encrypt and decrypt a message.
- How to generate secure deterministic noise.

## API

### XKyberCryptoBase

The main class for interacting with the xKyberCrypto library. It provides the following methods:

- `generateKeyPair()`: Generates a pair of public and private keys.
- `encrypt(Uint8List message, Uint8List publicKey)`: Encrypts a message using the public key.
- `decrypt(List<int> ciphertext, Uint8List privateKey)`: Decrypts an encrypted message using the private key.
- `generateNoise(Uint8List seed)`: Generates deterministic noise from a seed.

## Contributions

Contributions are welcome. To contribute:

1. Fork this repository.
2. Create a new branch for your changes (`git checkout -b feature/new-functionality`).
3. Make your changes and commit them (`git commit -m 'Add new functionality'`).
4. Push your changes to your repository (`git push origin feature/new-functionality`).
5. Open a Pull Request on this repository.

## License

This project is licensed under the MIT License. This encryption implementation is inspired by the Kyber algorithm and adheres to its standards for post-quantum encryption.
