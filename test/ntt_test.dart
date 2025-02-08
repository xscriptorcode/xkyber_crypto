import 'dart:core';
import 'package:xkyber_crypto/xkyber_crypto.dart';


/// Example to test the NTT and iNTT functions.
///
/// Shows how to apply the NTT and iNTT to a polynomial in Montgomery form.
/// The original polynomial is [0, 1, 2, ..., 255].
void main() {
  final List<int> original = List<int>.generate(256, (int i) => i);
  print("Original polynomial:");
  print(original);

  final List<int> mont = original.map(toMontgomery).toList();
  final List<int> transformed = ntt(mont);
  print("\nNTT (in Monty):");
  print(transformed);

  final List<int> invTransformed = invntt(transformed);
  print("\niNTT (in Monty):");
  print(invTransformed);

  final List<int> recovered = invTransformed.map(fromMontgomery).toList();
  print("\nRecovered (downgrading Monty to normal):");
  print(recovered);

  bool ok = true;
  for(int i=0; i<256; i++) {
    if(recovered[i] != original[i]) {
      ok = false;
      break;
    }
  }
  print("\n Is the same? $ok");
}
