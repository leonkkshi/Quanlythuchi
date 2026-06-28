import '../dtos/login_request_dto.dart';
import '../dtos/login_response_dto.dart';

abstract class IAuthRemoteDataSource {
  Future<LoginResponseDto> login(LoginRequestDto request);
  Future<void> logout(String token);
  Future<LoginResponseDto> register(String name, String email, String password);
  Future<void> forgotPassword(String email, String newPassword);
}
