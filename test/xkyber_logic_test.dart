import 'package:test/test.dart';
import 'package:xkyber_crypto/kyber_logic.dart';
import 'package:xkyber_crypto/polynomial.dart';
import 'package:xkyber_crypto/kyber_keypair.dart';
import 'package:xkyber_crypto/src/exceptions.dart';


void main() {
  group('Kyber Logic Tests', () {
    // Setup: Example values for testing
    final exampleKeyPair = KyberKeyPair.generate(
      privateKey: Polynomial([1, 2, 3, 4, 5]),
      publicKey: Polynomial([5, 4, 3, 2, 1]),
    );
    final exampleModulus = 7;
    final invalidPolynomial = Polynomial([]); // Empty polynomial as invalid object
    final invalidKeyPair = KyberKeyPair.generate(
      privateKey: invalidPolynomial,
      publicKey: invalidPolynomial,
    );

    test('Create shared key with valid inputs', () {
      final otherPublicKey = Polynomial([6, 5, 4, 3, 2]);
      final sharedKey = createSharedKey(exampleKeyPair, otherPublicKey, exampleModulus);

      expect(sharedKey.coefficients, isNotEmpty);
      expect(sharedKey.coefficients.length, exampleKeyPair.privateKey.coefficients.length);
    });

    test('Create shared key with invalid KeyPair throws exception', () {
      expect(
        () => createSharedKey(invalidKeyPair, Polynomial([6, 5, 4]), exampleModulus),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('Create shared key with invalid modulus throws exception', () {
      expect(
        () => createSharedKey(exampleKeyPair, Polynomial([6, 5, 4]), 0),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('Encrypt session data with null shared key throws exception', () {
      expect(
        () => encryptSession("Hello", invalidPolynomial, exampleModulus),
        throwsA(isA<InvalidInputException>()),
      );
    });
  });
}
