//testfile only for test
//shake128_test.dart
import 'dart:developer';
import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';

void testShake128() {
  // ignore: always_specify_types
  Uint8List input = Uint8List.fromList([1, 2, 3]);
  Uint8List output = shake128(input, 64);
  log("SHAKE128 Output (64 bytes): $output");
  // Here you should compare with an officially known vector. 
  // Example: assert(output == expectedVector)
}
