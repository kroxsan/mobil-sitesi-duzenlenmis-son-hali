import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  int? userId;
  String? username;

  final String apiUrl = "http://localhost:5151/api/auth";

  // ADMIN KONTROLÜ (backend’e kayıtlı username üzerinden)
  bool get isAdmin => username == 'admin1';

  bool get isLoggedIn => token != null;

  // Token'ı kalıcı depolamadan yükle
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userId = prefs.getInt('userId');
    username = prefs.getString('username');

    notifyListeners();
  }

  // Login
  Future<void> login(String usernameInput, String password) async {
    final response = await http.post(
      Uri.parse("$apiUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameInput,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data['token'];
      userId = data['userId'];
      username = usernameInput;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);
      await prefs.setInt('userId', userId!);
      await prefs.setString('username', username!);

      notifyListeners();
    } else {
      throw Exception("Giriş başarısız");
    }
  }

  //  Logout
  Future<void> logout() async {
    token = null;
    userId = null;
    username = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
