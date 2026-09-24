import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:templum_studdi/models/time.dart';
import 'package:templum_studdi/services/token.services.dart';

Future<Time?> getTime() async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await TokenService.getToken();
  final response = await http.get(
    Uri.parse('$apiUrl/time'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  if (response.statusCode == 200) {
    return Time.fromJson(jsonDecode(response.body));
  }
  if (response.statusCode == 404) {
    return null;
  }
  throw Exception(
    'Falha ao buscar tempo: ${response.statusCode} ${response.body}',
  );
}

Future<Time> defineTime(Duration defined) async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await TokenService.getToken();
  final response = await http.post(
    Uri.parse('$apiUrl/time'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode({'definedTime': _durationToHms(defined)}),
  );
  if (response.statusCode == 200) {
    return Time.fromJson(jsonDecode(response.body));
  }
  throw Exception(
    'Falha ao definir tempo semanal: ${response.statusCode} ${response.body}',
  );
}

Future<Time> StartTime() async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await TokenService.getToken();
  final response = await http.post(
    Uri.parse('$apiUrl/time/start'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  if (response.statusCode == 200) {
    return Time.fromJson(jsonDecode(response.body));
  }
  throw Exception(
    'Falha ao iniciar tempo: ${response.statusCode} ${response.body}',
  );
}

Future<Time> StopTime() async {
  final apiUrl = dotenv.env['API_URL'];
  final token = await TokenService.getToken();
  final response = await http.post(
    Uri.parse('$apiUrl/time/stop'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  if (response.statusCode == 200) {
    return Time.fromJson(jsonDecode(response.body));
  }
  throw Exception(
    'Falha ao pausar tempo: ${response.statusCode} ${response.body}',
  );
}

String _durationToHms(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}