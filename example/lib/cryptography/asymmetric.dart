import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> asymmetric(String key) async {
  final publicKey = await getPublicKey();
  final privateKey = await getPrivateKey();

  final encrypter =
      Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));

  final encrypted = encrypter.encrypt(key);
  final decrypted = encrypter.decrypt(encrypted);
  print("------------------hee");
  print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
  print(encrypted.base64); // Encrypted text

  // Store encrypted text
  return encrypted.base64;
}

Future<String> asymmetricdecrypt(String text) async {
  final publicKey = await getPublicKey();
  final privateKey = await getPrivateKey();

  final encrypter =
      Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));
        final encrypted = Encrypted.fromBase64(text);

  final decrypted = await encrypter.decrypt(encrypted);

  return decrypted;
}

Future<RSAPublicKey> getPublicKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? publicKeyString = await prefs.getString('publickey');
  if (publicKeyString != null) {
    return RSAKeyParser().parse(publicKeyString) as RSAPublicKey;
  }
  throw Exception('Public key not found in SharedPreferences');
}

Future<RSAPrivateKey> getPrivateKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? privateKeyString = await prefs.getString('privatekey');
  if (privateKeyString != null) {
    return RSAKeyParser().parse(privateKeyString) as RSAPrivateKey;
  }
  throw Exception('Private key not found in SharedPreferences');
}
