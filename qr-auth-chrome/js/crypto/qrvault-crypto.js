/**
 * QrAuthVault
 *
 * Crypto helpers library which uses 3rd party BigInt.js library
 *
 * 2015 (c) Valera Chevtaev
 */

if (typeof qrauth === "undefined") {
    qrauth = {};
}
qrauth.crypto = {};
qrauth.crypto.bits = 128;
qrauth.crypto.e = str2bigInt("65537", 10, 0);
qrauth.crypto.maxKey = 1073741824; // 2^30
qrauth.crypto.one = one; //int2bigInt(1, 1, 1);
qrauth.crypto.testStr = "asdasdasd";

// required to store latest value in the current context
qrauth.crypto.context = {};
qrauth.crypto.context.dhP = undefined;
qrauth.crypto.context.dhG = undefined;
qrauth.crypto.context.dhSecret = undefined;
qrauth.crypto.context.dhPubKey = undefined;
qrauth.crypto.context.dhPrivKey = undefined;
qrauth.crypto.context.dhPrivKeyStr = undefined;

qrauth.crypto.genRandomPrime = function(notCongruentToNum) {
    var primeNum;
    while (1) {
        primeNum = randProbPrime(qrauth.crypto.bits); // or randTruePrime()
        //the prime must not be congruent to 1 modulo e
        if (!equals(primeNum, notCongruentToNum) && !equalsInt(mod(primeNum, qrauth.crypto.e), 1)) {
            break;
        }
    }
    return primeNum;
};

// generate DH p
qrauth.crypto.genP = function() {
    var prime = qrauth.crypto.genRandomPrime(qrauth.crypto.one);
    qrauth.crypto.context.dhP = prime;
    return prime;
};

// generate DH g
qrauth.crypto.genG = function(p) {
    var prime = qrauth.crypto.genRandomPrime(p);
    qrauth.crypto.context.dhG = prime;
    return prime;
};

// random number as a secret
qrauth.crypto.genSecret = function() {
    var secret = Math.floor((Math.random() * qrauth.crypto.maxKey) + 1);
    secret = int2bigInt(secret, qrauth.crypto.bits, 1);
    qrauth.crypto.context.dhSecret = secret;
    return secret;
};

// public key = g^secret mod p
qrauth.crypto.evalPubKey = function(g, secret, p) {
    var key = powMod(g, secret, p);
    qrauth.crypto.context.dhPubKey = key;
    return key;
};

// private key = A^b mod p or B^a mod p
qrauth.crypto.evalPrivKey = function(A, b, p) {
    var key = powMod(A, b, p);
    qrauth.crypto.context.dhPrivKey = key;
    return key;
};

// generate private key
// resulting value is converted from bigint to string
qrauth.crypto.evalPrivKeyFromStr = function(A, b, p) {
    var key = qrauth.crypto.bigint2str(qrauth.crypto.evalPrivKey(qrauth.crypto.str2bigint(A), qrauth.crypto.str2bigint(b), qrauth.crypto.str2bigint(p)));
    qrauth.crypto.context.dhPrivKeyStr = key;
    return key;
};

// convert bigint variable to string
qrauth.crypto.bigint2str = function(bigintNum) {
    return bigInt2str(bigintNum, 10);
};

// convert string variable to bigint
qrauth.crypto.str2bigint = function(bigintStr) {
    return str2bigInt(bigintStr, 10, 0);
};
