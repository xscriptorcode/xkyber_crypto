// frommsg_tomsg_test.dart
// ignore_for_file: always_specify_types

import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void main() {
  group('polyfrommsg / polytomsg', () {
    test('should correctly convert a message to a polynomial and back', () {
      // Create a message Uint8List with values from 0 to KYBER_SYMBYTES - 1.
      final Uint8List msg = Uint8List.fromList(
          List<int>.generate(KYBER_SYMBYTES, (i) => i));

      // Convert the message into a polynomial.
      final Poly p = Poly();
      polyfrommsg(p, msg);

      // Convert the polynomial back to a message.
      final Uint8List decoded = Uint8List(KYBER_SYMBYTES);
      polytomsg(decoded, p);

      // Verify that the decoded message has the same length as the original message.
      expect(decoded.length, equals(msg.length));

      // Verify that each element of the decoded message is equal to the original.
      for (int i = 0; i < msg.length; i++) {
        expect(decoded[i], equals(msg[i]),
            reason: 'Mismatch at index $i: expected ${msg[i]}, got ${decoded[i]}');
      }
    });
  });
}
