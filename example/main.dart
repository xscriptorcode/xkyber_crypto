// /example/main.dart == example file
// ignore_for_file: avoid_print, always_specify_types

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:xkyber_crypto/kem.dart';
import 'package:xkyber_crypto/kyber_keypair.dart';

/// Dada la clave compartida ss (32 bytes) obtenida de Kyber, la usamos como SecretKey para AES-GCM.
Future<SecretKey> secretKeyFromSS(Uint8List ss) async {
  return SecretKey(ss);
}

/// Cifra data con AES-GCM usando secretKey
Future<String> encryptData(String data, SecretKey secretKey) async {
  final algorithm = AesGcm.with256bits();
  final nonce = algorithm.newNonce();
  final secretBox = await algorithm.encrypt(
    utf8.encode(data),
    secretKey: secretKey,
    nonce: nonce,
  );
  final combined = Uint8List.fromList(
      [...nonce, ...secretBox.cipherText, ...secretBox.mac.bytes]);
  return base64Encode(combined);
}

/// Descifra data con AES-GCM usando secretKey
Future<String> decryptData(String encryptedData, SecretKey secretKey) async {
  final algorithm = AesGcm.with256bits();
  final decoded = base64Decode(encryptedData);

  final nonce = decoded.sublist(0, algorithm.nonceLength);
  final cipherText =
      decoded.sublist(algorithm.nonceLength, decoded.length - 16);
  final macBytes = decoded.sublist(decoded.length - 16);
  final mac = Mac(macBytes);

  final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
  final decrypted = await algorithm.decrypt(secretBox, secretKey: secretKey);
  return utf8.decode(decrypted);
}

void main() async {
  // 1. Generate Kyber key pair
  KyberKeyPair keyPair = KyberKeyPair.generate();
  Uint8List pk = keyPair.publicKey;
  Uint8List sk = keyPair.secretKey;

  // Message
  String originalMessage = "Hello, this is a secret message";

  // 2. Encapsulate to get ss and c
  Uint8List c = Uint8List(768); // ciphertext size for Kyber512
  Uint8List ssSender = Uint8List(32);
  cryptokemenc(c, ssSender, pk);

  final secretKeySender = await secretKeyFromSS(ssSender);

  // 3. Encrypt the message with AES-GCM using ssSender
  String encryptedData = await encryptData(originalMessage, secretKeySender);

  // The sender sends (c, encryptedData) to the receiver

  // 4. The receiver decapsulates to get ssReceiver
  Uint8List ssReceiver = Uint8List(32);
  cryptokemdec(ssReceiver, c, sk);

  final secretKeyReceiver = await secretKeyFromSS(ssReceiver);

  // 5. Decrypt the encryptedData with ssReceiver
  String decryptedMessage = await decryptData(encryptedData, secretKeyReceiver);

  // 6. Verify
  assert(decryptedMessage == originalMessage);

  print("Original message: $originalMessage");
  print("Decrypted message: $decryptedMessage");
  print("The encryption/decryption process works correctly!");
}
