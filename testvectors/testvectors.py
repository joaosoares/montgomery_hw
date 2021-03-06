import helpers
import HW
import SW

import sys

operation = 0

print "TEST VECTOR GENERATOR FOR DDP\n"

if len(sys.argv) == 2:
  if str(sys.argv[1]) == "adder":           operation = 1;
  if str(sys.argv[1]) == "subtractor":      operation = 2;
  if str(sys.argv[1]) == "multiplication":  operation = 3;
  if str(sys.argv[1]) == "exponentiation":  operation = 4;
  if str(sys.argv[1]) == "crtrsa":          operation = 5;

#####################################################

if operation == 0:
  print "You should use this script by passing an argument like:"
  print " $ python testvectors.py adder"
  print " $ python testvectors.py subractor"
  print " $ python testvectors.py multiplication"
  print " $ python testvectors.py exponentiation"
  print " $ python testvectors.py crtrsa"

#####################################################

if operation == 1:
  print "Test Vector for Multi Precision Adder\n"

  A = helpers.getRandomInt(514)
  B = helpers.getRandomInt(514)
  C = HW.MultiPrecisionAdd(A,B,"add")

  print "A                = ", hex(A)           # 514-bits
  print "B                = ", hex(B)           # 514-bits
  print "A + B            = ", hex(C)           # 515-bits

#####################################################

if operation == 2:
  print "Test Vector for Multi Precision Subtractor\n"

  A = helpers.getRandomInt(514)
  B = helpers.getRandomInt(514)
  C = HW.MultiPrecisionAdd(A,B,"subtract")

  print "A                = ", hex(A)           # 514-bits
  print "B                = ", hex(B)           # 514-bits
  print "A - B            = ", hex(C)           # 515-bits

#####################################################

if operation == 3:
  print "Test Vector for Montgomery Multiplication\n"

  # A = helpers.getRandomInt(512)
  # B = helpers.getRandomInt(512)
  A = 0xb4d6d951f6532ac13ec6a44addbb552b3eca8fef9a81a1fd095485063c7ee4f89dcf19acf884fa9d0b6ce9c148e6b85af88024189c1da60e534acc6c7969363b
  B = 0x86eb6f8babc25f0986ba7460e46ffd91f34532c114485075f85ff900d4cf71d918be9ef170e1b84bca67755131efcbb767a2e069ad68c321a1cb985909098399
  M = 0x7e93fee7fd5d369339166e57cf5f773c1698c44b91a9f9a4be462bee6a82552d982845cd2787e90bc0245b4e781b9e1be10c615e2c814b3d85b78e358fa2c393
  C = HW.MontMulModified_512(A, B, M)
  D = (A*B*helpers.Modinv(2**512,M)) % M
  e = C - D
  
  print "A                = ", hex(A)         # 512-bits
  print "B                = ", hex(B)         # 512-bits
  print "M                = ", hex(M)         # 512-bits
  print "(A*B*R^-1) mod M = ", hex(C)         # 512-bits
  print "(A*B*R^-1) mod M = ", hex(D)         # 512-bits
  print "error            = ", hex(e)         
  
#####################################################

if operation == 4:

  print "Test Vector for Montgomery Exponentiation\n"

  X = helpers.getRandomInt(512)
  E = helpers.getRandomInt(8)
  M = helpers.getModulus(512)
  C = HW.MontExp_512(X, E, M)
  D = helpers.Modexp(X, E, M)
  e = C - D

  print "X                = ", hex(X)           # 512-bits
  print "E                = ", hex(E)           # 8-bits
  print "M                = ", hex(M)           # 512-bits
  print "(X^E) mod M      = ", hex(C)           # 512-bits
  print "(X^E) mod M      = ", hex(D)           # 512-bits
  print "error            = ", hex(e)         

#####################################################

if operation == 5:

  print "Test Vector for RSA\n"

  print "\n--- Precomputed Values"

  # Generate two primes (p,q), and modulus
  [p,q,N] = helpers.getModuli(512)

  print "p            = ", hex(p)               # 512-bits
  print "q            = ", hex(q)               # 512-bits
  print "Modulus      = ", hex(N)               # 1024-bits

  # Generate Exponents
  [e,d] = helpers.getRandomExponents(p,q) 

  print "Enc exp      = ", hex(e)               # 16-bits
  print "Dec exp      = ", hex(d)               # 1024-bits

  # Generate Message
  M     = helpers.getRandomMessage(1024,N)

  print "Message      = ", hex(M)               # 512-bits

  # For CRT RSA
  x_p   = q * helpers.Modinv(q, p)              
  x_q   = p * helpers.Modinv(p, q)              

  print "x_p          = ", hex(x_p)             # 1024-bits
  print "x_q          = ", hex(x_q)             # 1024-bits

  R    = 2**512
  R2p  = (R*R) % p
  R2q  = (R*R) % q
  R       = 2**1024
  R2_1024 = (R*R) % N

  print "R2_p         = ", hex(R2p)             # 1024-bits
  print "R2_q         = ", hex(R2q)             # 1024-bits
  print "R2_1024      = ", hex(R2_1024)         # 1024-bits

  #####################################################

  print "\n--- Execute RSA (For verification)"

  # Encrypt
  Ct1 = SW.MontExp_1024(M, e, N)                # 1024-bit exponentiation
  print "Ciphertext   = ", hex(Ct1)             # 512-bits

  # Decrypt
  Pt1 = SW.MontExp_1024(Ct1, d, N)              # 1024-bit exponentiation
  print "Plaintext    = ", hex(Pt1)             # 512-bits

  #####################################################

  print "\n--- Execute CRT RSA"

  #### Encrypt
  
  # Exponentiation, in Software
  Ct2 = SW.MontExp_1024(M, e, N)                # 1024-bit SW based montgomery exponentiation
  
  print "Ciphertext   = ", hex(Ct2)             # 1024-bits

  #### Decrypt

  # Reduction
  #
  # Here we reduce the ciphertext with p and q:
  #   Cp = Ciphertext mod p
  #   Cq = Ciphertext mod q
  #  
  # For this reduction, we divide the 1024-bit C
  # into two 512-bit blocks Ch and Cl such as:
  #   C = Ch * 2^512 + Cl
  #     = Ch * R     + Cl
  # 
  # Now we will reduce by using the formula:
  #   Cp = C mod p
  #      = (Ch * R + Cl)  mod p
  #      = (Ch * R^2 / R + Cl) mod p
  #      = (MontMul(Ch,R,p) + Cl) mod p
        
        # Ignore these lines
        # C_p = Ct2 % p;                        # 512-bits
        # C_q = Ct2 % q;                        # 512-bits        
        # print "Ciphertext_p = ", hex(C_p)     # 512-bits
        # print "Ciphertext_q = ", hex(C_q)     # 512-bits
  
  Ct2h = Ct2 >> 512;                            # 512-bits
  Ct2l = Ct2 % (2**512);                        # 512-bits

  tp   = HW.MontMul_512(Ct2h, R2p, p)           # 512-bits HW based montgomery multiplication
  tq   = HW.MontMul_512(Ct2h, R2q, q)           # 512-bits HW based montgomery multiplication

  Ct_p = (tp + Ct2l) % p                        # 512-bits modular addition
  Ct_q = (tq + Ct2l) % q                        # 512-bits modular addition

  print "Ciphertext_p = ", hex(Ct_p)            # 512-bits
  print "Ciphertext_q = ", hex(Ct_q)            # 512-bits

  # (Optional) Reduction of the decryption exponents, in Software
  #
  # Since decryption exponent is 1024-bits large, 
  # the exponentiation will take a long time to execute. 
  # Therefore, the exponenet can be reduced to 512-bits
  # for optimizing the operation.
  # Following, condition is provided for this reduction:

  reduce = 1
  if not reduce:
    d_p = d                                     # 1024-bits
    d_q = d                                     # 1024-bits
  else:
    d_p = d % (p-1)                             # 512-bits
    d_q = d % (q-1)                             # 512-bits

  # Exponentiation, in Hardware
  
  # P_p = HW.MontExp_512(C_p, d_p, p)           # 512-bit exponentiation
  # P_q = HW.MontExp_512(C_q, d_q, q)           # 512-bit exponentiation
  P_p = helpers.Modexp(Ct_p, d_p, p)            # 512-bit exponentiation
  P_q = helpers.Modexp(Ct_q, d_q, q)            # 512-bit exponentiation
  
  # Inverse CRT, in Software
  #
  # We need to execute the following operation to combine the 
  # two 512-bit partial plaintext results P_p and P_q for calculating
  # the final 1024-bit plaintext:
  # 
  #   Plaintext = (P_p*x_p + P_q*x_q) mod N;
  #               (512-bits * 1024-bits) + (512-bits * 1024-bits)
  #
  # To simplify this calculation we will use the following formula
  # with a 1024-bit montgomery multiplication function, implemented
  # in software
  #
  #   Plaintext =  (P_p*x_p + P_q*x_q) mod N;
  #             = ((P_p*x_p/R + P_q*x_q/R) * R^2 / R) mod N;
  #             = ((MontMul(P_p,x_p,N) + MontMul(P_q,x_q,N)) * R^2 / R) mod N
  #             =  MontMul((MontMul(P_p,x_p,N) + MontMul(P_q,x_q,N)), R^2, N) mod N

        # Ignore these lines
        # Pt2 = (P_p*x_p + P_q*x_q) mod N;
        # print "Plaintext_p  = ", hex(P_p)     # 512-bits
        # print "Plaintext_q  = ", hex(P_q)     # 512-bits
        # print "Pt2          = ", hex(Pt2)     # (512-bits * 1024-bits) + (512-bits * 1024-bits)

  tp      = SW.MontMul_1024(P_p,x_p,N);         # 1024-bit SW based montgomery multiplication
  tq      = SW.MontMul_1024(P_q,x_q,N);         # 1024-bit SW based montgomery multiplication
  s       = (tp + tq) % N                       # 1024-bit SW based addition
  Pt3     = SW.MontMul_1024(s , R2_1024, N);    # 1024-bit SW based montgomery multiplication

  print "Plaintext    = ", hex(Pt3)             # 1024-bits