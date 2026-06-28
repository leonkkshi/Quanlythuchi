import '../../domain/entities/user.dart';

abstract class IAuthService {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> checkAuthStatus();
  Future<User> register(String name, String email, String password);
  Future<void> forgotPassword(String email, String newPassword);
}
