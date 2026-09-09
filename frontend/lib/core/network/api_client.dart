import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.isSuccess,
    this.message = '',
    this.data,
    required this.statusCode,
  });
}

class ApiClient {
  static String? _authToken;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  static Future<ApiResponse<dynamic>> get(String url) async {
    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      return _parseResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, message: e.toString(), statusCode: 500);
    }
  }

  static Future<ApiResponse<dynamic>> post(String url, Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _parseResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, message: e.toString(), statusCode: 500);
    }
  }

  static Future<ApiResponse<dynamic>> put(String url, Map<String, dynamic> body) async {
    try {
      final res = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _parseResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, message: e.toString(), statusCode: 500);
    }
  }

  static Future<ApiResponse<dynamic>> uploadMultipart(
    String url, {
    required List<int> fileBytes,
    required String filename,
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      });

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response);
    } catch (e) {
      return ApiResponse(isSuccess: false, message: e.toString(), statusCode: 500);
    }
  }

  static Future<ApiResponse<dynamic>> delete(String url, {Map<String, dynamic>? data}) async {
    try {
      final res = await http.delete(
        Uri.parse(url),
        headers: _headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return _parseResponse(res);
    } catch (e) {
      return ApiResponse(isSuccess: false, message: e.toString(), statusCode: 500);
    }
  }

  static ApiResponse<dynamic> _parseResponse(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      return ApiResponse(
        isSuccess: isSuccess,
        message: json['message'] ?? (isSuccess ? 'Success' : 'Error'),
        data: json['data'] ?? json,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: response.statusCode >= 200 && response.statusCode < 300,
        message: response.body,
        statusCode: response.statusCode,
      );
    }
  }
}
