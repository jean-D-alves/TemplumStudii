import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:templum_studdi/models/user.dart';
import 'package:templum_studdi/services/token.services.dart';

Future<User> requestme() async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await TokenService.getToken();
  final response = await http.get(
    Uri.parse('$apiUrl/user/me'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return User.fromJson(json);
  } else {
    throw Exception('Falha ao buscar usuário: ${response.statusCode} ${response.body}');
  }
}

Future<User> deleteme() async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await TokenService.getToken();
  final response = await http.delete(
    Uri.parse('$apiUrl/user'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return User.fromJson(json);
  } else {
    throw Exception('Falha ao buscar usuário: ${response.statusCode} ${response.body}');
  }
}

Future<User> Login(String email, String password) async {
  final apiUrl = dotenv.env['API_URL'];
  try {
    
    final response = await http.post(
      Uri.parse('$apiUrl/user/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      await TokenService.saveToken(json['token']);
      return User.fromJson(json['user']);
    } else {
      throw Exception("Falha ao buscar usuário: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Erro: ${e}");
  }
}
Future<User> CreateUser(String name, String email, String password, String studies) async {
  final apiUrl = dotenv.env['API_URL'];
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/user'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'studies': studies,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      await TokenService.saveToken(json['token']);
      return User.fromJson(json['user']);
    } else {
      throw Exception("Falha ao criar usuário: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Erro: ${e}");
  }
}
