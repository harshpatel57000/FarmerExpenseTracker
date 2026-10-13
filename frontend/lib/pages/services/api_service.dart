import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Physical Android phone and computer must be on the same Wi-Fi.
  // Spring Boot backend runs on port 8081.
  static const String baseUrl = 'http://10.252.120.188:8081';

  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';

  // ============================================================
  // COMMON HTTP METHODS
  // Every endpoint explicitly starts with /api/...
  // ============================================================

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token = await getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final uri = _uri(path);
    late http.Response response;

    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;

      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;

      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;

      case 'PATCH':
        response = await http.patch(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;

      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;

      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    print('$method $uri');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    dynamic data;

    if (response.body.trim().isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = response.body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data is Map
        ? (data['message'] ??
              data['error'] ??
              data['detail'] ??
              data.toString())
        : (data?.toString() ?? 'Request failed');

    throw Exception('$message (HTTP ${response.statusCode})');
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Expected a JSON object, received: $data');
  }

  
static List<dynamic> _asList(dynamic response) {
  // The server response may already be decoded,
  // or it may still be a JSON String.
  final dynamic decoded =
      response is String ? jsonDecode(response) : response;

  if (decoded is List) {
    return decoded;
  }

  throw Exception(
    'Expected a JSON list, received: ${decoded.runtimeType}',
  );
}


  // ============================================================
  // TOKEN STORAGE
  // ============================================================

  static Future<void> _saveTokenFromResponse(dynamic data) async {
    if (data is! Map) return;

    final token =
        data['token'] ??
        data['jwt'] ??
        data['accessToken'] ??
        data['access_token'];

    if (token is String && token.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save the logged-in user's ID.
  static Future<void> _saveUserIdFromResponse(dynamic data) async {
    if (data is! Map) return;

    // Supports common backend response field names.
    final rawUserId = data['userId'] ?? data['id'] ?? data['user_id'];

    if (rawUserId == null) return;

    final userId = rawUserId is int
        ? rawUserId
        : int.tryParse(rawUserId.toString());

    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userIdKey, userId);
    }
  }

  // Read the logged-in user's ID.
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  // POST /api/auth/login
  static Future<dynamic> loginWithPassword({
    required String loginId,
    required String password,
  }) async {
    final isEmail = loginId.contains('@');

    final data = await _request(
      'POST',
      '/api/auth/login',
      body: {
        if (isEmail) 'emailId': loginId,
        if (!isEmail) 'phoneNumber': loginId,
        'password': password,
      },
    );

    await _saveTokenFromResponse(data);
    await _saveUserIdFromResponse(data);
    return data;
  }

  // POST /api/auth/signup
  static Future<dynamic> signup({
    required String userName,
    required String emailId,
    required String phoneNumber,
    required String password,
  }) async {
    return _request(
      'POST',
      '/api/auth/signup',
      body: {
        'userName': userName,
        'emailId': emailId,
        'phoneNumber': phoneNumber,
        'password': password,
      },
    );
  }

  // POST /api/auth/loginOtp
  static Future<dynamic> sendLoginOtp({required String emailId}) async {
    return _request('POST', '/api/auth/loginOtp', body: {'emailId': emailId});
  }

  // POST /api/auth/verifyLoginOtp
  static Future<dynamic> verifyLoginOtp({
    required String emailId,
    required String otp,
  }) async {
    final data = await _request(
      'POST',
      '/api/auth/verifyLoginOtp',
      body: {'emailId': emailId, 'otp': otp},
    );

    await _saveTokenFromResponse(data);
    await _saveUserIdFromResponse(data);
    return data;
  }

  // POST /api/auth/verifySignupOtp
  static Future<dynamic> verifySignupOtp({
    required String emailId,
    required String otp,
  }) async {
    final data = await _request(
      'POST',
      '/api/auth/verifySignupOtp',
      body: {'emailId': emailId, 'otp': otp},
    );

    await _saveTokenFromResponse(data);
    await _saveUserIdFromResponse(data);
    return data;
  }

  // ============================================================
  // VILLAGE
  // ============================================================

  // GET /api/village
  

  // GET /api/village
  static Future<List<dynamic>> getVillages() async {
    final response = await _request(
      'GET',
      '/api/village',
      authenticated: true, // Send JWT token
    );

    dynamic decoded = response;

    if (decoded is String) {
      decoded = jsonDecode(decoded);
    }

    // Handle either a direct List or a Map containing the village list.
    if (decoded is Map) {
      decoded = decoded['LIST OF ALL VILLAGE :'];
    }

    if (decoded is List) {
      return decoded;
    }

    throw Exception(
      'Invalid village response: ${decoded.runtimeType}',
    );
  }



  // GET /api/village/{id}
  static Future<dynamic> getVillageById(int id) async {
    return _request('GET', '/api/village/$id');
  }

  // POST /api/village
  static Future<dynamic> addVillage({
    required String name,
    required String pinCode,
  }) async {
    return _request(
      'POST',
      '/api/village',
      body: {'name': name, 'pinCode': pinCode},
      authenticated: true,
    );
  }

  // PUT /api/village/{id}
  static Future<dynamic> updateVillage(
    int id, {
    required Map<String, dynamic> body,
  }) async {
    return _request('PUT', '/api/village/$id', body: body, authenticated: true);
  }

  // DELETE /api/village/{id}
  static Future<dynamic> deleteVillage(int id) async {
    return _request('DELETE', '/api/village/$id', authenticated: true);
  }

  // ============================================================
  // REGION
  // ============================================================

  // GET /api/region
  static Future<List<dynamic>> getRegions() async {
    return _asList(await _request('GET', '/api/region',authenticated: true,),);
  }

  // GET /api/region/{id}
  static Future<dynamic> getRegionById(int id) async {
    return _request('GET', '/api/region/$id');
  }

  // POST /api/region
  static Future<Map<String, dynamic>> addRegion({
    required String name,
    required int villageId,
  }) async {
    return _asMap(
      await _request(
        'POST',
        '/api/region',
        body: {'name': name, 'villageId': villageId},
        authenticated: true,
      ),
    );
  }

  // DELETE /api/region/{id}
  static Future<dynamic> deleteRegion(int id) async {
    return _request('DELETE', '/api/region/$id', authenticated: true);
  }

  // ============================================================
  // FARM
  // ============================================================

  // GET /api/farm
  static Future<List<dynamic>> getFarms() async {
    return _asList(await _request('GET', '/api/farm', authenticated: true),);
  }

  // GET /api/farm/{id}
  static Future<dynamic> getFarmById(int id) async {
    return _request('GET', '/api/farm/$id');
  }

  // POST /api/farm
  static Future<Map<String, dynamic>> addFarm({
    required String name,
    required double area,
    required int regionId,
  }) async {
    return _asMap(
      await _request(
        'POST',
        '/api/farm',
        body: {'name': name, 'area': area, 'regionId': regionId},
        authenticated: true,
      ),
    );
  }

  // DELETE /api/farm/{id}
  static Future<dynamic> deleteFarm(int id) async {
    return _request('DELETE', '/api/farm/$id', authenticated: true);
  }

  

// ============================================================
// CROP CYCLE
// ============================================================

// GET /api/cropcycle/farm/{farmId}
static Future<List<dynamic>> getCropCyclesByFarm(
  int farmId,
) async {
  return _asList(
    await _request(
      'GET',
      '/api/cropcycle/farm/$farmId',
      authenticated: true,
    ),
  );
}

// POST /api/cropcycle
static Future<dynamic> addCropCycle({
  required Map<String, dynamic> body,
}) async {
  return _request(
    'POST',
    '/api/cropcycle',
    body: body,
    authenticated: true,
  );
}

// PUT /api/cropcycle/{id}/complete
static Future<dynamic> completeCropCycle(
  int id, {
  required String endDate,
}) async {
  return _request(
    'PUT',
    '/api/cropcycle/$id/complete',
    body: {'endDate': endDate},
    authenticated: true,
  );
}

  // ============================================================
  // AGRO EXPENSE
  // ============================================================

  // GET /api/agro
  static Future<List<dynamic>> getAgroExpenses() async {
    return _asList(await _request('GET', '/api/agro', authenticated: true));
  }

  // GET /api/agro/{id}
  static Future<dynamic> getAgroExpenseById(int id) async {
    return _request('GET', '/api/agro/$id', authenticated: true);
  }

  // POST /api/agro
  static Future<dynamic> addAgroExpense({
    required Map<String, dynamic> body,
  }) async {
    return _request('POST', '/api/agro', body: body, authenticated: true);
  }

  // PUT /api/agro/{id}
  static Future<dynamic> updateAgroExpense(
    int id, {
    required Map<String, dynamic> body,
  }) async {
    return _request('PUT', '/api/agro/$id', body: body, authenticated: true);
  }

  // PATCH /api/agro/{id}
  static Future<dynamic> patchAgroExpense(
    int id, {
    required Map<String, dynamic> body,
  }) async {
    return _request('PATCH', '/api/agro/$id', body: body, authenticated: true);
  }

  // DELETE /api/agro/{id}
  static Future<dynamic> deleteAgroExpense(int id) async {
    return _request('DELETE', '/api/agro/$id', authenticated: true);
  }

  // ============================================================
  // FARM EXPENSE
  // ============================================================

  // GET /api/farm_expense
  static Future<List<dynamic>> getFarmExpenses() async {
    return _asList(
      await _request('GET', '/api/farm_expense', authenticated: true),
    );
  }

  // GET /api/farm_expense/{id}
  static Future<dynamic> getFarmExpenseById(int id) async {
    return _request('GET', '/api/farm_expense/$id', authenticated: true);
  }

  // POST /api/farm_expense
  static Future<dynamic> addFarmExpense({
    required Map<String, dynamic> body,
  }) async {
    return _request(
      'POST',
      '/api/farm_expense',
      body: body,
      authenticated: true,
    );
  }

  // PUT /api/farm_expense/{id}
  static Future<dynamic> updateFarmExpense(
    int id, {
    required Map<String, dynamic> body,
  }) async {
    return _request(
      'PUT',
      '/api/farm_expense/$id',
      body: body,
      authenticated: true,
    );
  }

  // PATCH /api/farm_expense/{id}
  static Future<dynamic> patchFarmExpense(
    int id, {
    required Map<String, dynamic> body,
  }) async {
    return _request(
      'PATCH',
      '/api/farm_expense/$id',
      body: body,
      authenticated: true,
    );
  }

  // DELETE /api/farm_expense/{id}
  static Future<dynamic> deleteFarmExpense(int id) async {
    return _request('DELETE', '/api/farm_expense/$id', authenticated: true);
  }
}
