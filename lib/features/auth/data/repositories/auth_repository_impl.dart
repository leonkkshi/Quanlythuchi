import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/i_auth_local_data_source.dart';
import '../datasources/i_auth_remote_data_source.dart';
import '../dtos/login_request_dto.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;
  final UserMapper _userMapper;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource remoteDataSource,
    required IAuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _userMapper = UserMapper();

  @override
  Future<User> login(String email, String password) async {
    final requestDto = LoginRequestDto(email: email, password: password);
    
    // Call remote to authenticate
    final responseDto = await _remoteDataSource.login(requestDto);
    
    // Save token and user details locally
    await _localDataSource.saveToken(responseDto.token);
    await _localDataSource.saveUser(responseDto.user);
    
    // Return domain user entity
    return _userMapper.toEntity(responseDto.user);
  }

  @override
  Future<void> logout() async {
    final token = await _localDataSource.getToken();
    if (token != null) {
      try {
        await _remoteDataSource.logout(token);
      } catch (_) {
        // Suppress remote logout errors during sign-out to guarantee local state clearance
      }
    }
    await _localDataSource.clear();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userDto = await _localDataSource.getUser();
    if (userDto == null) return null;
    return _userMapper.toEntity(userDto);
  }

  @override
  Future<String?> getToken() async {
    return _localDataSource.getToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }
}
