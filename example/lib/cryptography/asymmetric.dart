import 'dart:async';
import 'dart:convert';
import 'dart:io';
// ignore: library_prefixes
import 'package:fast_rsa/fast_rsa.dart' as fastRsa;

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> asymmetric(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? publicKeyString = prefs.getString('publickey');

  RSAPublicKey publicKey = await getPublicKey(publicKeyString!);
  final privateKey = await getPrivateKey();
  final encryptedData = await fastRsa.RSA.encryptOAEP(key, '', fastRsa.Hash.SHA256,publicKeyString);
  return encryptedData;
  // final encrypter =
  //     Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));

  // final encrypted = encrypter.encrypt(key);
  // final decrypted = encrypter.decrypt(encrypted);
  // print("------------------hee");
  // print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
  // print(encrypted.base64); // Encrypted text

  // // Store encrypted text
  // return encrypted.base64;
}

Future<String> asymmetricreceiver(String key, String syskey) async {
  final publicKey = await getPublicKey(key);
  print("-----@@@");
    final encryptedData = await fastRsa.RSA.encryptOAEP(syskey, '', fastRsa.Hash.SHA256, key);
  return encryptedData;

  // final encrypter = Encrypter(RSA(publicKey: publicKey));
  // print("-----^^^");

  // final encrypted = encrypter.encrypt(syskey);
  // print("------------------hee");
  // print(encrypted.base64); // Encrypted text

  // // Store encrypted text
  // return encrypted.base64;
}

// Future<String> asymmetricdecrypt(String key) async {
//   final privateKey = await getPrivateKey();
//   print("-----@@@t");
//   print("------$privateKey");
//   final encrypter = Encrypter(RSA(privateKey: privateKey));
//   print("-----@@@");
//   final encrypted = Encrypted.fromBase64(key);
//   print("--------$encrypted");
//   final chunkSize = 2048;

//   // Calculate the number of chunks
//   final numChunks = (encrypted.bytes.length / chunkSize).ceil();

//   // Create a completer to hold the decrypted data
//   Completer<String> completer = Completer<String>();

//   // List to hold decrypted chunks
//   List<String> decryptedChunks = [];

//   // Decrypt each chunk asynchronously
//   for (int i = 0; i < numChunks; i++) {
//     // Calculate start and end index for the current chunk
//     final startIndex = i * chunkSize;
//     final endIndex = (i + 1) * chunkSize;

//     // Extract the chunk
//     final chunk = encrypted.bytes.sublist(startIndex, endIndex);

//     // Perform decryption asynchronously using compute
//     await compute(
//             decryptChunkInBackground, {'encrypter': encrypter, 'chunk': chunk})
//         .then((decryptedChunk) {
//       decryptedChunks.add(decryptedChunk); // Add decrypted chunk to the list
//     });
//   }

//   // Concatenate decrypted chunks to form the complete decrypted data
//   String decryptedData = decryptedChunks.join('');

//   // Resolve the completer with decrypted data
//   completer.complete(decryptedData);

//   // Return the future from the completer
//   return completer.future;
// }

// // Function to decrypt a chunk of data in a separate isolate
// String decryptChunkInBackground(Map<String, dynamic> args) {
//   final encrypter = args['encrypter'] as Encrypter;
//   final chunk = args['chunk'] as Uint8List;

//   // Decrypt the chunk
//   return encrypter.decryptBytes(Encrypted(chunk)).toString();
// }
// //   Completer<String> completer = Completer<String>();

// //   // Perform decryption asynchronously
// //   Future(() {
// //     final decrypted = encrypter.decrypt(encrypted);
// //     completer.complete(decrypted); // Resolve the future with decrypted data
// //   });

// //   // Return the future
// //   return completer.future;
// //   // final decrypted = encrypter.decrypt(encrypted);
// //   // print("---------------$decrypted");
// //   // return decrypted;
// // }

Future<String> decryptRSA(String key) async {
   
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? privateKeyString = prefs.getString('privatekey');

  // Decrypt the payload using RSA decryption with OAEP padding and SHA256 hash
  final decryptedData = await fastRsa.RSA.decryptOAEP(key, '', fastRsa.Hash.SHA256, privateKeyString!);
  return decryptedData;
}
Future<String> asymmetricdecrypt(String key) async {
  final privateKey = await getPrivateKey();
  print("-----@@@t");
  print("------$privateKey");
  final encrypter = Encrypter(RSA(privateKey: privateKey));
  print("-----@@@");
  final encrypted = Encrypted.fromBase64(key);
  print("--------$encrypted");

  // Define chunk size (adjust as needed)
  const chunkSize = 256; // Lower chunk size to avoid out-of-bounds errors

  // Calculate the number of chunks
  final numChunks = (encrypted.bytes.length / chunkSize).ceil();

  // Create a completer to hold the decrypted data
  Completer<String> completer = Completer<String>();

  // List to hold decrypted chunks
  List<String> decryptedChunks = [];

  // Decrypt each chunk asynchronously
  for (int i = 0; i < numChunks; i++) {
    // Calculate start and end index for the current chunk
    final startIndex = i * chunkSize;
    final endIndex = startIndex + chunkSize; // Use endIndex = startIndex + chunkSize

    // Extract the chunk
    final chunk = Uint8List.fromList(encrypted.bytes.sublist(startIndex, endIndex)); // Convert to Uint8List

    // Perform decryption asynchronously using compute
    await compute(decryptChunkInBackground, {'encrypter': encrypter, 'chunk': chunk}).then((decryptedChunk) {
      decryptedChunks.add(decryptedChunk); // Add decrypted chunk to the list
    });
  }

  // Concatenate decrypted chunks to form the complete decrypted data
  String decryptedData = decryptedChunks.join('');

  // Resolve the completer with decrypted data
  completer.complete(decryptedData);

  // Return the future from the completer
  return completer.future;
}

// Function to decrypt a chunk of data in a separate isolate
String decryptChunkInBackground(Map<String, dynamic> args) {
  final encrypter = args['encrypter'] as Encrypter;
  final chunk = args['chunk'] as Uint8List; // Change parameter type to Uint8List

  // Decrypt the chunk
  return encrypter.decryptBytes(Encrypted(chunk)).toString();
}
Future<RSAPublicKey> getPublicKey(String publicKeyString) async {
  if (publicKeyString.isNotEmpty) {
    final publickey = RSAKeyParser().parse(publicKeyString) as RSAPublicKey;

    return publickey;
  }
  throw Exception('Public key not found in SharedPreferences');
}

Future<RSAPrivateKey> getPrivateKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? privateKeyString = prefs.getString('privatekey');
  print(privateKeyString);
  if (privateKeyString!.isNotEmpty) {
    final privateKey = RSAKeyParser().parse(privateKeyString) as RSAPrivateKey;
    print("-----$privateKey");
    return privateKey;
  }
  throw Exception('Private key not found in SharedPreferences');
}
