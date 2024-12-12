//testfile only for test
//frommsg_tomsg_test.dart
// ignore_for_file: always_specify_types

import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';
/// Test polyfrommsg and polytomsg functions.
///
/// The test creates a Uint8List `msg` with values from 0 to KYBER_SYMBYTES-1,
/// converts it to a polynomial `p` using polyfrommsg, and then converts it
/// back to a Uint8List `decoded` using polytomsg.
///
/// The test asserts that the length of `decoded` is the same as `msg` and
/// that each element of `decoded` is equal to the corresponding element of
/// `msg`. Finally, it prints a success message to the console.
void testPolyFromToMsg() {
  Uint8List msg = Uint8List.fromList(List.generate(KYBER_SYMBYTES, (i) => i));
  Poly p = Poly();
  polyfrommsg(p, msg);
  
  Uint8List decoded = Uint8List(KYBER_SYMBYTES);
  polytomsg(decoded, p);
  
  assert(decoded.length == msg.length);
  for (int i = 0; i < msg.length; i++) {
    assert(decoded[i] == msg[i]);
  }
  // ignore: avoid_print
  print("polyfrommsg / polytomsg test passed!");
}
