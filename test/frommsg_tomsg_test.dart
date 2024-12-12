import 'dart:typed_data';
import 'package:xkyber_crypto/xkyber_crypto.dart';
void testPolyFromToMsg() {
  Uint8List msg = Uint8List.fromList(List.generate(KYBER_SYMBYTES, (i) => i));
  Poly p = Poly();
  poly_frommsg(p, msg);
  
  Uint8List decoded = Uint8List(KYBER_SYMBYTES);
  poly_tomsg(decoded, p);
  
  assert(decoded.length == msg.length);
  for (int i = 0; i < msg.length; i++) {
    assert(decoded[i] == msg[i]);
  }
  print("poly_frommsg / poly_tomsg test passed!");
}
