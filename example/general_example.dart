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
  KyberEncapsulationResult encapsulationResult =
      KyberKEM.encapsulate(keypair.publicKey);
  Uint8List ciphertext = encapsulationResult.ciphertextKEM;
  Uint8List sharedSecretEnc = encapsulationResult.sharedSecret;
  print("\nCiphertext (${ciphertext.length} bytes):");
  print(ciphertext);
  print("\nEncapsulated Shared Secret (${sharedSecretEnc.length} bytes):");
  print(sharedSecretEnc);

  // 3. Decapsulation
  // Using the secret key, decapsulate to recover the shared secret.
  Uint8List sharedSecretDec =
      KyberKEM.decapsulate(ciphertext, keypair.secretKey);
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
