// fq.dart
//
// Operations in the field modulo q.

import 'params.dart';

int fqadd(int a, int b) {
  int r = a + b;
  if (r >= KYBER_Q) r -= KYBER_Q;
  return r;
}

int fqsub(int a, int b) {
  int r = a - b;
  if (r < 0) r += KYBER_Q;
  return r;
}
