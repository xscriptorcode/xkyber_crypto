// lib/crypto/ntt.dart

int mod(int a, int m) => ((a % m) + m) % m;
int modAdd(int a, int b, int m) => mod(a + b, m);
int modSub(int a, int b, int m) => mod(a - b, m);
int modMul(int a, int b, int m) => mod(a * b, m);

List<int> ntt(List<int> poly, int modulus, int root) {
  int n = poly.length;
  List<int> result = List<int>.from(poly);
  for (int length = 1; length < n; length *= 2) {
    int wlen = modPow(root, (modulus - 1) ~/ (2 * length), modulus);
    for (int i = 0; i < n; i += 2 * length) {
      int w = 1;
      for (int j = 0; j < length; j++) {
        int u = result[i + j];
        int v = modMul(result[i + j + length], w, modulus);
        result[i + j] = modAdd(u, v, modulus);
        result[i + j + length] = modSub(u, v, modulus);
        w = modMul(w, wlen, modulus);
      }
    }
  }
  return result;
}

List<int> intt(List<int> poly, int modulus, int invRoot) {
  int n = poly.length;
  List<int> result = List<int>.from(poly);
  for (int length = n ~/ 2; length > 0; length ~/= 2) {
    int wlen = modPow(invRoot, (modulus - 1) ~/ (2 * length), modulus);
    for (int i = 0; i < n; i += 2 * length) {
      int w = 1;
      for (int j = 0; j < length; j++) {
        int u = result[i + j];
        int v = result[i + j + length];
        result[i + j] = modAdd(u, v, modulus);
        result[i + j + length] = modMul(modSub(u, v, modulus), w, modulus);
        w = modMul(w, wlen, modulus);
      }
    }
  }
  int nInv = modPow(n, modulus - 2, modulus);
  for (int i = 0; i < n; i++) {
    result[i] = modMul(result[i], nInv, modulus);
  }
  return result;
}

int modPow(int base, int exp, int modulus) {
  int result = 1;
  while (exp > 0) {
    if ((exp & 1) != 0) {
      result = modMul(result, base, modulus);
    }
    base = modMul(base, base, modulus);
    exp >>= 1;
  }
  return result;
}
