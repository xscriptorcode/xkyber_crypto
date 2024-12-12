import 'dart:typed_data';
import 'package:xkyber_crypto/params.dart';
import 'package:xkyber_crypto/kem.dart';         // Para crypto_kem_keypair, crypto_kem_enc, crypto_kem_dec
import 'package:xkyber_crypto/kyber_keypair.dart'; // Nuestra clase KyberKeyPair que usa el kem real

/// Clase principal de la biblioteca xKyberCrypto que proporciona
/// funcionalidades de cifrado post-cuántico basado en Kyber.
///
/// Esta clase ahora:
/// - Genera un par de claves Kyber (publicKey, privateKey).
/// - Encapsula una clave compartida usando la publicKey.
/// - Descapsula la clave compartida usando la privateKey.
/// - Usa la clave compartida `ss` obtenida del KEM para cifrar/descifrar un mensaje con un cifrado simétrico simple.

class XKyberCryptoBase {

  /// Genera un par de claves pública y privada utilizando Kyber.
  /// Retorna un objeto KyberKeyPair con publicKey y secretKey.
  KyberKeyPair generateKeyPair() {
    return KyberKeyPair.generate(); 
  }

  /// Encapsula una clave compartida utilizando la llave pública (publicKey).
  /// Retorna un mapa con el ciphertext KEM y la sharedSecret.
  Map<String, Uint8List> encapsulate(Uint8List publicKey) {
    Uint8List c = Uint8List(KYBER_CIPHERTEXTBYTES);
    Uint8List ss = Uint8List(KYBER_SSBYTES);
    crypto_kem_enc(c, ss, publicKey);
    return {
      'ciphertextKEM': c,
      'sharedSecret': ss
    };
  }

  /// Descapsula el ciphertext KEM usando la llave privada (privateKey)
  /// para recuperar la sharedSecret.
  Uint8List decapsulate(Uint8List ciphertextKEM, Uint8List privateKey) {
    Uint8List ss = Uint8List(KYBER_SSBYTES);
    crypto_kem_dec(ss, ciphertextKEM, privateKey);
    return ss;
  }

  /// Cifra un mensaje dado utilizando la sharedSecret derivada del KEM.
  /// Aquí usamos un cifrado simétrico muy simple (XOR) solo como ejemplo.
  /// En un entorno real, usar AES-GCM u otro cifrador autenticado.
  Uint8List encryptMessage(Uint8List message, Uint8List sharedSecret) {
    // Supongamos sharedSecret es nuestra "key".
    // XOR no es seguro, pero sirve de ejemplo.
    Uint8List ciphertext = Uint8List(message.length);
    for (int i = 0; i < message.length; i++) {
      ciphertext[i] = message[i] ^ sharedSecret[i % sharedSecret.length];
    }
    return ciphertext;
  }

  /// Descifra un mensaje usando la sharedSecret.
  /// Con XOR, el descifrado es igual al cifrado.
  Uint8List decryptMessage(Uint8List ciphertext, Uint8List sharedSecret) {
    Uint8List plaintext = Uint8List(ciphertext.length);
    for (int i = 0; i < ciphertext.length; i++) {
      plaintext[i] = ciphertext[i] ^ sharedSecret[i % sharedSecret.length];
    }
    return plaintext;
  }
}
