import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';
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
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network latency

    if (path.endsWith('/auth/login')) {
      final email = body?['email'] as String?;
      final password = body?['password'] as String?;

      if (email == null || password == null) {
        throw InvalidInputException('Email và mật khẩu không được để trống.');
      }

      final user = await DatabaseHelper.instance.getUserByEmail(email);
      if (user != null && user['password'] == password) {
        return {
          'token': 'mockToken_${user['id']}',
          'user': {
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'avatarUrl': user['avatarUrl'],
          }
        };
      } else {
        throw UnauthorizedException('Tên đăng nhập hoặc mật khẩu không chính xác.');
      }
    }

    if (path.endsWith('/auth/register')) {
      final name = body?['name'] as String?;
      final email = body?['email'] as String?;
      final password = body?['password'] as String?;

      if (name == null || email == null || password == null) {
        throw InvalidInputException('Thông tin đăng ký không hợp lệ.');
      }

      final exists = await DatabaseHelper.instance.checkUserExists(email);
      if (exists) {
        throw InvalidInputException('Email đã được đăng ký bởi tài khoản khác.');
      }

      final id = 'u_${DateTime.now().millisecondsSinceEpoch}';
      final avatarUrl = 'https://api.dicebear.com/7.x/adventurer/svg?seed=${Uri.encodeComponent(name)}';

      final newUser = {
        'id': id,
        'name': name,
        'email': email.toLowerCase().trim(),
        'password': password,
        'avatarUrl': avatarUrl,
      };

      await DatabaseHelper.instance.insertUser(newUser);

      return {
        'token': 'mockToken_$id',
        'user': {
          'id': id,
          'name': name,
          'email': email,
          'avatarUrl': avatarUrl,
        }
      };
    }

    if (path.endsWith('/auth/forgot-password')) {
      final email = body?['email'] as String?;
      final newPassword = body?['password'] as String?;

      if (email == null || newPassword == null) {
        throw InvalidInputException('Thông tin đặt lại mật khẩu không hợp lệ.');
      }

      final exists = await DatabaseHelper.instance.checkUserExists(email);
      if (!exists) {
        throw InvalidInputException('Email không tồn tại trong hệ thống.');
      }

      await DatabaseHelper.instance.updatePassword(email, newPassword);

      return {
        'success': true,
        'message': 'Đổi mật khẩu thành công.'
      };
    }
    
    throw ServerException('Endpoint mock not implemented.');
  }

  Future<Map<String, dynamic>> _simulateMockGet(String path, Map<String, String>? headers) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final token = headers?['Authorization'];
    if (token == null) {
      throw UnauthorizedException('Phiên đăng nhập không hợp lệ.');
    }

    final index = token.indexOf('mockToken_');
    if (index == -1) {
      throw UnauthorizedException('Token không hợp lệ.');
    }
    final userId = token.substring(index + 'mockToken_'.length).trim();

    if (path.endsWith('/auth/profile')) {
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        return {
          'id': user['id'],
          'name': user['name'],
          'email': user['email'],
          'avatarUrl': user['avatarUrl'],
        };
      } else {
        throw UnauthorizedException('Không tìm thấy tài khoản người dùng.');
      }
    }

    throw ServerException('Endpoint mock not implemented.');
  }
}
