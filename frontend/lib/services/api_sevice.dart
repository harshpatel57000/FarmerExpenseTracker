import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl =
      'https://localhost:8081';

  static Future<Map<String, dynamic>> addRegion({
    required String name,
    required int villageId,
  }) async {

    final response = await http.post(
      Uri.parse('$baseUrl/api/region'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'name': name,
        'villageId': villageId,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      return jsonDecode(response.body);
    }

    throw Exception(
      'Region API Error: '
      '${response.statusCode}\n'
      '${response.body}',
    );
  }

  static Future<Map<String, dynamic>> addFarm({
    required String name,
    required int regionId,
  }) async {

    final response = await http.post(
      Uri.parse('$baseUrl/api/farm'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'name': name,
        'regionId': regionId,
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      return jsonDecode(response.body);
    }

    throw Exception(
      'Farm API Error: '
      '${response.statusCode}\n'
      '${response.body}',
    );
  }
}