import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Physical phone: use your currently working laptop IP.
  // USB reverse: use http://127.0.0.1:8081 and run:
  // adb reverse tcp:8081 tcp:8081
  static const String baseUrl = 'http://10.244.72.152:8081';

  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  // ============================================================
  // COMMON HTTP METHODS
  // ============================================================

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    bool retryOnUnauthorized = true,
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

    // Do not print authentication responses because they may contain tokens.
    if (path.startsWith('/api/auth/')) {
      print('BODY: [authentication response hidden]');
    } else {
      print('BODY: ${response.body}');
    }

    dynamic data;

    if (response.body.trim().isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = response.body;
      }
    }

    // Refresh an expired access token once.
    if (response.statusCode == 401 &&
        authenticated &&
        retryOnUnauthorized &&
        path != '/api/auth/refresh' &&
        path != '/api/auth/logout') {
      final refreshed = await _refreshAccessToken();

      if (refreshed) {
        return _request(
          method,
          path,
          body: body,
          authenticated: true,
          retryOnUnauthorized: false,
        );
      }

      await _clearSession();
      throw Exception('Session expired. Please log in again.');
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
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception('Expected a JSON object, received: $data');
  }

  static List<dynamic> _asList(dynamic response) {
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

    final accessToken = data['token'] ??
        data['jwt'] ??
        data['accessToken'] ??
        data['access_token'];

    final refreshToken = data['refreshToken'] ?? data['refresh_token'];

    final prefs = await SharedPreferences.getInstance();

    if (accessToken is String && accessToken.isNotEmpty) {
      await prefs.setString(_tokenKey, accessToken);
    }

    if (refreshToken is String && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> _saveUserIdFromResponse(dynamic data) async {
    if (data is! Map) return;

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

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }

  /// Restores a saved session by refreshing the access token.
  static Future<bool> restoreSession() async {
    final refreshToken = await getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearSession();
      return false;
    }

    try {
      return await _refreshAccessToken();
    } catch (_) {
      // Preserve the saved session if the server is temporarily unreachable.
      print('Session restoration could not reach the server.');
      return false;
    }
  }

  // ============================================================
  // REFRESH ACCESS TOKEN
  // POST /api/auth/refresh
  // ============================================================

  static Future<bool> _refreshAccessToken() async {
    final refreshToken = await getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final response = await http.post(
      _uri('/api/auth/refresh'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    print('POST ${_uri('/api/auth/refresh')}');
    print('REFRESH STATUS: ${response.statusCode}');
    print('REFRESH BODY: [hidden]');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      await _clearSession();
      return false;
    }

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      await _clearSession();
      return false;
    }

    if (data is! Map) {
      await _clearSession();
      return false;
    }

    final accessToken = data['token'] ??
        data['jwt'] ??
        data['accessToken'] ??
        data['access_token'];

    final newRefreshToken = data['refreshToken'] ?? data['refresh_token'];

    // Both tokens are required because the backend rotates refresh tokens.
    if (accessToken is! String ||
        accessToken.isEmpty ||
        newRefreshToken is! String ||
        newRefreshToken.isEmpty) {
      await _clearSession();
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, newRefreshToken);

    return true;
  }

  // ============================================================
  // LOGOUT
  // POST /api/auth/logout
  // ============================================================

  static Future<void> logout() async {
    final refreshToken = await getRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await http.post(
          _uri('/api/auth/logout'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }
    } finally {
      await _clearSession();
    }
  }

  // ============================================================
  // AUTHENTICATION
  // ============================================================

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

  static Future<dynamic> sendLoginOtp({
    required String emailId,
  }) async {
    return _request(
      'POST',
      '/api/auth/loginOtp',
      body: {'emailId': emailId},
    );
  }

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
  // PROFILE
  // GET /api/auth/profile
  // PUT /api/auth/profile
  // ============================================================

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await _request(
      'GET',
      '/api/auth/profile',
      authenticated: true,
    );

    return _asMap(response);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String userName,
    required String phoneNumber,
  }) async {
    final response = await _request(
      'PUT',
      '/api/auth/profile',
      body: {
        'userName': userName,
        'phoneNumber': phoneNumber,
      },
      authenticated: true,
    );

    return _asMap(response);
  }

  // ============================================================
  // REGION
  // User -> Region -> Farm
  // No Village API or villageId.
  // ============================================================

  static Future<List<dynamic>> getRegions() async {
    return _asList(
      await _request(
        'GET',
        '/api/region',
        authenticated: true,
      ),
    );
  }

  static Future<dynamic> getRegionById(int id) async {
    return _request(
      'GET',
      '/api/region/$id',
      authenticated: true,
    );
  }

  static Future<Map<String, dynamic>> addRegion({
    required String name,
  }) async {
    return _asMap(
      await _request(
        'POST',
        '/api/region',
        body: {'name': name},
        authenticated: true,
      ),
    );
  }

  static Future<dynamic> deleteRegion(int id) async {
    return _request(
      'DELETE',
      '/api/region/$id',
      authenticated: true,
    );
  }

  // ============================================================
  // FARM
  // ============================================================

  static Future<List<dynamic>> getFarms() async {
    return _asList(
      await _request(
        'GET',
        '/api/farm',
        authenticated: true,
      ),
    );
  }

  static Future<dynamic> getFarmById(int id) async {
    return _request(
      'GET',
      '/api/farm/$id',
      authenticated: true,
    );
  }

  static Future<Map<String, dynamic>> addFarm({
    required String name,
    required double area,
    required int regionId,
  }) async {
    return _asMap(
      await _request(
        'POST',
        '/api/farm',
        body: {
          'name': name,
          'area': area,
          'regionId': regionId,
        },
        authenticated: true,
      ),
    );
  }

  static Future<dynamic> deleteFarm(int id) async {
    return _request(
      'DELETE',
      '/api/farm/$id',
      authenticated: true,
    );
  }

  // ============================================================
  // CROP CYCLE
  // ============================================================

  static Future<List<dynamic>> getCropCyclesByFarm(int farmId) async {
    return _asList(
      await _request(
        'GET',
        '/api/cropcycle/farm/$farmId',
        authenticated: true,
      ),
    );
  }

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

  static Future<List<dynamic>> getAgroExpenses() async {
    return _asList(
      await _request(
        'GET',
        '/api/agro',
        authenticated: true,
      ),
    );
  }

  static Future<dynamic> getAgroExpenseById(int id) async {
    return _request(
      'GET',
      '/api/agro/$id',
      authenticated: true,
    );
  }

  static Future<dynamic> addAgroExpense({
    required Map<String, dynamic> body,
  }) async {
    return _request(
      'POST',
      '/api/agro',
      body: body,
      authenticated: true,
    );
  }

  static Future<dynamic> updateAgroExpense(
    int id, {
    required Map<String, dynamic> body,
  }) async {
    return _request(
      'PUT',
      '/api/agro/$id',
      body: body,
      authenticated: true,
    );
  }

  static Future<dynamic> patchAgroExpense(
    int id, {
    required Map<String, dynamic> body,
  }) async {
    return _request(
      'PATCH',
      '/api/agro/$id',
      body: body,
      authenticated: true,
    );
  }

  static Future<dynamic> deleteAgroExpense(int id) async {
    return _request(
      'DELETE',
      '/api/agro/$id',
      authenticated: true,
    );
  }

  // ============================================================
  // FARM EXPENSE
  // ============================================================

  static Future<List<dynamic>> getFarmExpenses() async {
    return _asList(
      await _request(
        'GET',
        '/api/farm_expense',
        authenticated: true,
      ),
    );
  }

  static Future<dynamic> getFarmExpenseById(int id) async {
    return _request(
      'GET',
      '/api/farm_expense/$id',
      authenticated: true,
    );
  }

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

  static Future<dynamic> deleteFarmExpense(int id) async {
    return _request(
      'DELETE',
      '/api/farm_expense/$id',
      authenticated: true,
    );
  }

  // ============================================================
  // SEARCH FARM EXPENSES
  // ============================================================

  Future<Map<String, dynamic>> searchFarmExpenses({
    required String cropName,
    required int year,
    int page = 0,
    int size = 20,
  }) async {
    final query = <String, String>{
      'cropName': cropName,
      'year': year.toString(),
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': 'expenseDate',
      'direction': 'desc',
    };

    final queryString = Uri(queryParameters: query).query;

    final response = await _request(
      'GET',
      '/api/farm_expense/search?$queryString',
      authenticated: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Invalid expense response from server');
  }
}