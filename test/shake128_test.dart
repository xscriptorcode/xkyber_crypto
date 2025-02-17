// shake128_test.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart'; // Asegúrate de que shake.dart esté exportado

void main() {
  group('SHAKE128 Function', () {
    test('SHAKE128 generates non-zero output for random input', () {
      Uint8List input = Uint8List.fromList([1, 2, 3, 4, 5]);
      Uint8List output = shake128(input, 32);
      // Verifica que al menos un byte sea distinto de cero.
      bool nonZero = output.any((b) => b != 0);
      expect(nonZero, isTrue, reason: 'SHAKE128 returned all zeros.');
      print('SHAKE128 output (Base64): ${base64Encode(output)}');
    });
  });
}
