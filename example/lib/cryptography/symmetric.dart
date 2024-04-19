import 'package:encrypt/encrypt.dart';
import 'dart:math';

import 'package:example/cryptography/asymmetric.dart';

String generateRandomString(int length) {
  const alphanumeric =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  final chars = List.generate(
    length,
    (index) => alphanumeric.codeUnitAt(random.nextInt(alphanumeric.length)),
  );
  return String.fromCharCodes(chars);
}

Future<List> cryptoclient(String text) async {
  final key1 = generateRandomString(32);
  print(key1);
  final key = Key.fromUtf8(key1);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final encrypted = encrypter.encrypt(text, iv: iv);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  print("-----------------------------------");
  print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
  print(encrypted
      .base64); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1YecJeZMAop/hZ4OxqgC1WtwvX/hP9mw==
  String keyenc = await asymmetric(key1);
  List list = [keyenc, encrypted.base64, iv.base64];
  return list;
}

Future<List> cryptoreceiver(String text, String clkey) async {
  final key1 = generateRandomString(32);
  print(key1);
  final key = Key.fromUtf8(key1);
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final encrypted = encrypter.encrypt(text, iv: iv);
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  print("-----------------------------------hddfdif");
  print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
  print(encrypted
      .base64); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1YecJeZMAop/hZ4OxqgC1WtwvX/hP9mw==
  String keyenc = await asymmetricreceiver(clkey, key1);
  List list = [keyenc, encrypted.base64, iv.base64];
  return list;
}

Future<String> decrypt(String text, String k, String v) async {
//  final key = await asymmetricdecrypt(k);
  final key = await decryptRSA(k);
  final encrypted = Encrypted.fromBase64(text);
  final iv = IV.fromBase64(v); // Decode IV from base64
  print("000000");
  final encrypter = Encrypter(AES(Key.fromUtf8(key)));
  final decrypted = encrypter.decrypt(encrypted, iv: iv);
  print(decrypted);
  return decrypted;
}
