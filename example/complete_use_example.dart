import 'dart:typed_data';

import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  final XKyberCryptoBase xkyber = XKyberCryptoBase();

  // 1. Generar llaves
  KyberKeyPair keyPair = xkyber.generateKeyPair();
  Uint8List pk = keyPair.publicKey; // Public Key
  Uint8List sk = keyPair.secretKey; // Private Key

  // Mensaje a cifrar
  String mensajeOriginal = "Hola, este es un mensaje secreto";
  Uint8List mensajeBytes = Uint8List.fromList(mensajeOriginal.codeUnits);

  // 2. El emisor encapsula una clave compartida usando la pk del receptor
  Map<String, Uint8List> encapsResult = xkyber.encapsulate(pk);
  Uint8List cKEM = encapsResult['ciphertextKEM']!;
  Uint8List ss_sender = encapsResult['sharedSecret']!; // Clave compartida en el emisor

  // 3. Con la clave compartida ss_sender, el emisor cifra el mensaje
  Uint8List ciphertextSym = xkyber.encryptMessage(mensajeBytes, ss_sender);

  // Ahora el emisor envía al receptor: (cKEM, ciphertextSym)

  // 4. El receptor recibe cKEM y ciphertextSym, usa su sk para descapsular la sharedSecret
  Uint8List ss_receiver = xkyber.decapsulate(cKEM, sk);

  // 5. El receptor descifra el ciphertextSym con ss_receiver
  Uint8List mensajeDescifrado = xkyber.decryptMessage(ciphertextSym, ss_receiver);
  String mensajeRecuperado = String.fromCharCodes(mensajeDescifrado);

  // 6. Verificar que el mensaje descifrado es igual al original
  assert(mensajeRecuperado == mensajeOriginal);

  print("Mensaje original: $mensajeOriginal");
  print("Mensaje descifrado: $mensajeRecuperado");
  print("El proceso de cifrado/descifrado funciona correctamente!");
}
