import '../dtos/login_request_dto.dart';
import '../dtos/login_response_dto.dart';

abstract class IAuthRemoteDataSource {
  Future<LoginResponseDto> login(LoginRequestDto request);
  Future<void> logout(String token);
}
