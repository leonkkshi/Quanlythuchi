import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../dtos/login_request_dto.dart';
import '../dtos/login_response_dto.dart';
import 'i_auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: request.toJson(),
    );
    return LoginResponseDto.fromJson(response);
  }

  @override
  Future<void> logout(String token) async {
    await _apiClient.post(
      ApiConstants.logout,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  @override
  Future<LoginResponseDto> register(String name, String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
    return LoginResponseDto.fromJson(response);
  }

  @override
  Future<void> forgotPassword(String email, String newPassword) async {
    await _apiClient.post(
      ApiConstants.forgotPassword,
      body: {
        'email': email,
        'password': newPassword,
      },
    );
  }
}
