import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // HTTP Client with custom timeout
  static final http.Client _client = http.Client();

  // Generic headers
  static Map<String, String> get _headers => {'Content-Type': 'application/json', 'Accept': 'application/json'};

  // Generic error handling
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? data['error'] ?? 'خطأ في الخادم',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'خطأ في تحليل الاستجابة', 'statusCode': response.statusCode};
    }
  }

  // User Authentication
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.signInEndpoint}');
      final body = json.encode({'email': email, 'password': password});

      final response = await _client.post(url, headers: _headers, body: body).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'لا يوجد اتصال بالإنترنت'};
    } on HttpException {
      return {'success': false, 'error': 'خطأ في الاتصال بالخادم'};
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // User Registration
  static Future<Map<String, dynamic>> signUp(String email, String password, String name) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.signUpEndpoint}');
      final body = json.encode({'email': email, 'password': password, 'name': name});

      final response = await _client.post(url, headers: _headers, body: body).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'لا يوجد اتصال بالإنترنت'};
    } on HttpException {
      return {'success': false, 'error': 'خطأ في الاتصال بالخادم'};
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Get user sessions
  static Future<Map<String, dynamic>> getUserSessions(String userId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.sessionsEndpoint}');
      final body = json.encode({'userId': userId});

      final response = await _client.post(url, headers: _headers, body: body).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'لا يوجد اتصال بالإنترنت'};
    } on HttpException {
      return {'success': false, 'error': 'خطأ في الاتصال بالخادم'};
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Validate mobile call
  static Future<Map<String, dynamic>> validateMobileCall(String callerId, String calleeEmail) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.validateCallEndpoint}');
      final body = json.encode({'callerId': callerId, 'calleeEmail': calleeEmail});

      final response = await _client.post(url, headers: _headers, body: body).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'لا يوجد اتصال بالإنترنت'};
    } on HttpException {
      return {'success': false, 'error': 'خطأ في الاتصال بالخادم'};
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Close session
  static Future<Map<String, dynamic>> closeSession() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.sessionCloseEndpoint}');

      final response = await _client.get(url, headers: _headers).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'لا يوجد اتصال بالإنترنت'};
    } on HttpException {
      return {'success': false, 'error': 'خطأ في الاتصال بالخادم'};
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Delete latest session for user
  static Future<Map<String, dynamic>> deleteLatestSession(String userId) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.deleteLatestSessionEndpoint}/$userId');

      final response = await _client.delete(url, headers: _headers).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'لا يوجد اتصال بالإنترنت'};
    } on HttpException {
      return {'success': false, 'error': 'خطأ في الاتصال بالخادم'};
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Open session
  static Future<Map<String, dynamic>> openSession() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.sessionOpenEndpoint}');

      final response = await _client.get(url, headers: _headers).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'لا يوجد اتصال بالإنترنت'};
    } on HttpException {
      return {'success': false, 'error': 'خطأ في الاتصال بالخادم'};
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Update user
  static Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.usersEndpoint}/$userId');
      final body = json.encode(userData);

      final response = await _client.put(url, headers: _headers, body: body).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'لا يوجد اتصال بالإنترنت'};
    } on HttpException {
      return {'success': false, 'error': 'خطأ في الاتصال بالخادم'};
    } catch (e) {
      return {'success': false, 'error': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // Dispose client
  static void dispose() {
    _client.close();
  }
}
