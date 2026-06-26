import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'i_auth_service.dart';

class AuthServiceImpl implements IAuthService {
  final IAuthRepository _authRepository;

  AuthServiceImpl({required IAuthRepository authRepository}) : _authRepository = authRepository;

  @override
  Future<User> login(String email, String password) async {
    return _authRepository.login(email, password);
  }

  @override
  Future<void> logout() async {
    await _authRepository.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return _authRepository.getCurrentUser();
  }

  @override
  Future<bool> checkAuthStatus() async {
    return _authRepository.isAuthenticated();
  }
}
