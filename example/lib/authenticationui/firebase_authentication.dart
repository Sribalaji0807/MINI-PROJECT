import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import SharedPreferences for mobile platforms
import 'package:shared_preferences/shared_preferences.dart';

// Import LocalStorage for web platforms
import 'package:universal_html/html.dart' as html;

// Import your UserInfoData and DBservice classes
import 'package:example/Database/DatabaseService.dart';
import 'package:http/http.dart' as http;

class Authservice {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> register(String name, String email, String password) async {
    try {
      UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String? userId = user.user?.uid;
      print(userId);

      // Save user information based on the platform
      if (!kIsWeb) {
        // For mobile platforms (using SharedPreferences)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userid', userId ?? '');
        await prefs.setString('username', name);
        await prefs.setString('useremail', email);
        await prefs.setBool('isLoggedIn', true);
        fetchKeys();
      } else {
        // For web platform (using LocalStorage)
        html.window.localStorage['userid'] = userId ?? '';
        html.window.localStorage['username'] = name;
        html.window.localStorage['useremail'] = email;
        html.window.localStorage['isLoggedIn'] = 'true';
      }

      DBservice db = DBservice(id: userId ?? '');
      await db.addUserData(name, email);
      print("User registration successful");

      return name; // Registration successful, return "success" indicating no error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the error message
    } catch (e) {
      print('Error during registration: $e');
      return 'An unexpected error occurred'; // Return a generic error message
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String? userId = user.user?.uid;
      print("--------------------------");
      print("User login successful");
      print(userId);

      // Retrieve user information from database based on the platform
      DBservice db = DBservice(id: userId ?? '');
      String name = await db.retriveuserinfo(userId ?? '');

      // Save user information based on the platform
      if (!kIsWeb) {
        // For mobile platforms (using SharedPreferences)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userid', userId ?? '');
        await prefs.setString('username', name);
        await prefs.setString('useremail', email);
        await prefs.setBool('isLoggedIn', true);
                fetchKeys();

      } else {
        // For web platform (using LocalStorage)
        html.window.localStorage['userid'] = userId ?? '';
        html.window.localStorage['username'] = name;
        html.window.localStorage['useremail'] = email;
        html.window.localStorage['isLoggedIn'] = 'true';
      }

      return userId; // Login successful, return "success" indicating no error
    } on FirebaseAuthException catch (e) {
      return e.message; // Return the error message
    } catch (e) {
      print('Error during login: $e');
      return 'An unexpected error occurred'; // Return a generic error message
    }
  }

  Future<void> fetchKeys() async {
    final url = Uri.parse('https://key-gen-xg3m.vercel.app/key');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);    
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('publickey', body['public']);
      await prefs.setString('privatekey', body['private']);
      String? id =prefs.getString('userid');
      DBservice db = DBservice(id: id);
      db.setPublicKey(body['public']);
    } else {
      print('Failed to fetch keys: ${response.statusCode}');
    }
  }
}
