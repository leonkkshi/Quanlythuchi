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
}
