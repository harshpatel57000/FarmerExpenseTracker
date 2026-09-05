import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8081';

  // =========================
  // ADD VILLAGE
  // =========================

  static Future<Map<String, dynamic>> addVillage({required String name}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/village'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    return _handleResponse(response, 'Add Village');
  }

  // =========================
  // ADD REGION
  // =========================

  static Future<Map<String, dynamic>> addRegion({
    required String name,
    required int villageId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/region'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'villageId': villageId}),
    );

    return _handleResponse(response, 'Add Region');
  }

  // =========================
  // ADD FARM
  // =========================

  static Future<Map<String, dynamic>> addFarm({
    required String name,
    required int regionId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/farm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'regionId': regionId}),
    );

    return _handleResponse(response, 'Add Farm');
  }

  // =========================
  // RESPONSE HANDLER
  // =========================

  static Map<String, dynamic> _handleResponse(
    http.Response response,
    String operation,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return {};
      }

      return jsonDecode(response.body);
    }

    throw Exception(
      '$operation failed\n'
      'Status: ${response.statusCode}\n'
      'Response: ${response.body}',
    );
  }
}
