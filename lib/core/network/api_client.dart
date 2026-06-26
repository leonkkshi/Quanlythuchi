import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exception.dart';

class ApiClient {
  final http.Client _client;
  
  // Toggle this to true for demonstration/local testing without a backend
  final bool useMock = true;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    if (useMock) {
      return _simulateMockPost(path, body);
    }

    final uri = Uri.parse('https://api.quanlythuchi.example.com$path');
    try {
      final response = await _client.post(
        uri,
        body: body != null ? json.encode(body) : null,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Connection failed. Please check your network.');
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? headers}) async {
    if (useMock) {
      return _simulateMockGet(path, headers);
    }

    final uri = Uri.parse('https://api.quanlythuchi.example.com$path');
    try {
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Connection failed. Please check your network.');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (statusCode == 401 || statusCode == 403) {
      throw UnauthorizedException('Session expired or unauthorized credentials.');
    } else if (statusCode >= 400 && statusCode < 500) {
      throw InvalidInputException('Invalid request data.');
    } else {
      throw ServerException('Server returned code $statusCode');
    }
  }

  // --- MOCK SIMULATION FOR DEMO ---
  Future<Map<String, dynamic>> _simulateMockPost(String path, Map<String, dynamic>? body) async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate network latency

    if (path.endsWith('/auth/login')) {
      final email = body?['email'] as String?;
      final password = body?['password'] as String?;

      if (email == 'admin@example.com' && password == 'password123') {
        return {
          'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mockToken123',
          'user': {
            'id': 'u-001',
            'name': 'Nguyễn Văn Minh',
            'email': 'admin@example.com',
            'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/svg?seed=Minh',
          }
        };
      } else {
        throw UnauthorizedException('Tên đăng nhập hoặc mật khẩu không chính xác.');
      }
    }
    
    throw ServerException('Endpoint mock not implemented.');
  }

  Future<Map<String, dynamic>> _simulateMockGet(String path, Map<String, String>? headers) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final token = headers?['Authorization'];
    if (token == null || !token.contains('mockToken123')) {
      throw UnauthorizedException('Invalid or missing authentication token.');
    }

    if (path.endsWith('/auth/profile')) {
      return {
        'id': 'u-001',
        'name': 'Nguyễn Văn Minh',
        'email': 'admin@example.com',
        'avatarUrl': 'https://api.dicebear.com/7.x/adventurer/svg?seed=Minh',
      };
    }

    throw ServerException('Endpoint mock not implemented.');
  }
}
