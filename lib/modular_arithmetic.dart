// lib/crypto/moudular_aritmethic.dart

int mod(int a, int m) => ((a % m) + m) % m;
int modAdd(int a, int b, int m) => mod(a + b, m);
int modSub(int a, int b, int m) => mod(a - b, m);
int modMul(int a, int b, int m) => mod(a * b, m);

int modInverse(int a, int m) {
  int m0 = m, t, q;
  int x0 = 0, x1 = 1;

  if (m == 1){
  return 0;

  }
    
  while (a > 1) {
    q = a ~/ m;
    t = m;

    m = a % m;
    a = t;
    t = x0;

    x0 = x1 - q * x0;
    x1 = t;
  }

  if (x1 < 0){
  x1 += m0;

  }
    
  return x1;
}
