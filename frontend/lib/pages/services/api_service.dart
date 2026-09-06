import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ============================================================
  // BASE URL
  // ============================================================

  // Android Emulator -> Windows computer localhost
  static const String baseUrl =
      'http://localhost:8081/api';

  // ============================================================
  // VILLAGE
  // ============================================================

  // GET ALL VILLAGES
  static Future<List<dynamic>> getVillages() async {
  final response = await http.get(
    Uri.parse('$baseUrl/village'),
  );

  print('GET VILLAGES STATUS: ${response.statusCode}');
  print('GET VILLAGES BODY: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    // Backend returns:
    // {"LIST OF ALL VILLAGE\n:":[ ... ]}

    if (data is Map) {
      for (final entry in data.entries) {
        if (entry.value is List) {
          return List<dynamic>.from(entry.value);
        }
      }
    }

    // If backend directly returns a List
    if (data is List) {
      return data;
    }

    throw Exception('Village list not found in response');
  }

  throw Exception(
    'Failed to load villages. Status: ${response.statusCode}',
  );
}
  // ADD VILLAGE
  static Future<String> addVillage({
    required String name,
    required String pinCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/village'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'name': name,
        'pinCode': pinCode,
      }),
    );

    print('ADD VILLAGE STATUS: ${response.statusCode}');
    print('ADD VILLAGE BODY: ${response.body}');

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception(
        'Failed to add village: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  // ============================================================
  // REGION
  // ============================================================

  // GET ALL REGIONS
  static Future<List<dynamic>> getRegions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/region'),
    );

    print('GET REGIONS STATUS: ${response.statusCode}');
    print('GET REGIONS BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return List<dynamic>.from(data);
      }

      throw Exception(
        'Unexpected region response: $data',
      );
    } else {
      throw Exception(
        'Failed to load regions: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  // ADD REGION
  static Future<Map<String, dynamic>> addRegion({
    required String name,
    required int villageId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/region'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'name': name,
        'villageId': villageId,
      }),
    );

    print('ADD REGION STATUS: ${response.statusCode}');
    print('ADD REGION BODY: ${response.body}');

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        'Failed to add region: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  // ============================================================
  // FARM
  // ============================================================

  // GET ALL FARMS
  static Future<List<dynamic>> getFarms() async {
    final response = await http.get(
      Uri.parse('$baseUrl/farm'),
    );

    print('GET FARMS STATUS: ${response.statusCode}');
    print('GET FARMS BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return List<dynamic>.from(data);
      }

      throw Exception(
        'Unexpected farm response: $data',
      );
    } else {
      throw Exception(
        'Failed to load farms: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  // ADD FARM
  static Future<Map<String, dynamic>> addFarm({
    required String name,
    required double area,
    required int regionId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/farm'),

      headers: {
        'Content-Type': 'application/json',
      },

      body: jsonEncode({
        'name': name,
        'area': area,
        'regionId': regionId,
      }),
    );

    print('ADD FARM STATUS: ${response.statusCode}');
    print('ADD FARM BODY: ${response.body}');

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Map<String, dynamic>.from(
        jsonDecode(response.body),
      );
    } else {
      throw Exception(
        'Failed to add farm: '
        '${response.statusCode} ${response.body}',
      );
    }
  }
}