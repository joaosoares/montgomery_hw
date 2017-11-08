import random
import math

import sys
sys.setrecursionlimit(1500)

def getModuli(bits):
    N = 1
    while bitlen(N) != bits*2:
        p     = getRandomPrime(bits)
        q     = getRandomPrime(bits)
        N     = p*q
    return [p,q,N]

def getModulus(bits):
    n = random.randrange(2**(bits-1), 2**bits-1)
    # print gcd(n, 2**bits)
    while not gcd(n, 2**bits) == 1:
        n = random.randrange(2**(bits-1), 2**bits-1)
    mod = n
    return n

def getRandomMessage(bits,M):
    return random.randrange(2**(bits-1), M); 

def getRandomMessageForCRT(p,q):
    if p < q:
        M = p
    else:
        M = q
    return random.randrange(M); 

def getRandomPrime(bits):
    n = random.randrange(2**(bits-1), 2**bits-1)
    while not isPrime(n):
        n = random.randrange(2**(bits-1), 2**bits-1)
    return n

def getRandomInt(bits):
    return random.randrange(2**(bits-1), 2**bits-1)

def getRandomExponents(p, q):
    phi = (p-1)*(q-1)
    e = getRandomPrime(16)
    while not gcd(e, phi) == 1:
        e = getRandomPrime(16)
    d = Modinv(e,phi)
    return [e,d]

def isPrime(n, k=5): # miller-rabin
    from random import randint
    if n < 2: return False
    for p in [2,3,5,7,11,13,17,19,23,29]:
        if n % p == 0: return n == p
    s, d = 0, n-1
    while d % 2 == 0:
        s, d = s+1, d/2
    for i in range(k):
        x = pow(randint(2, n-1), d, n)
        if x == 1 or x == n-1: continue
        for r in range(1, s):
            x = (x * x) % n
            if x == 1: return False
            if x == n-1: break
        else: return False
    return True

def bitlen(n):
    return int(math.log(n, 2)) + 1

def bit(y,index):
  bits   = [(y >> i) & 1 for i in range(1024)]
  bitstr = ''.join([chr(sum([bits[i * 8 + j] << j for j in range(8)])) for i in range(1024/8)])
  return (ord(bitstr[index/8]) >> (index%8)) & 1

def gcd(x, y):
    while y != 0:
        (x, y) = (y, x % y)
    return x

def Modexp(b,e,m):
  if e == 0: return 1
  t = Modexp(b,e/2,m)**2 % m
  if e & 1: t = (t*b) % m
  return t

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def Modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        return -1
    else:
        return x % m