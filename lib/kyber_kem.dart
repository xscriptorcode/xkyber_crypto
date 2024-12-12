// kyber_kem.dart
//
// Now that we have the real logic in kem.dart, this file can be a wrapper.
import 'dart:typed_data';
import 'params.dart';
import 'kem.dart';

class KyberEncapsulationResult {
  final Uint8List ciphertextKEM;
  final Uint8List sharedSecret;
  KyberEncapsulationResult(this.ciphertextKEM, this.sharedSecret);
}

class KyberKEM {
  // generate keypair real
  static KyberEncapsulationResult encapsulate(Uint8List pk) {
    Uint8List c = Uint8List(KYBER_CIPHERTEXTBYTES);
    Uint8List ss = Uint8List(KYBER_SSBYTES);
    cryptokemenc(c, ss, pk);
    return KyberEncapsulationResult(c, ss);
  }

  /// Decapsulates the given ciphertext using the provided private key to recover
  /// the shared secret.
  ///
  /// This method takes a ciphertext generated during the encapsulation process
  /// and a private key, and uses them to retrieve the original shared secret.
  ///
  /// Parameters:
  /// - `c`: The ciphertext to be decapsulated.
  /// - `sk`: The private key corresponding to the public key used in encapsulation.
  ///
  /// Returns:
  /// A `Uint8List` containing the shared secret.
  static Uint8List decapsulate(Uint8List c, Uint8List sk) {
    Uint8List ss = Uint8List(KYBER_SSBYTES);
    cryptokemdec(ss, c, sk);
    return ss;
  }
}
