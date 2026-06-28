import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<String?> getToken();
  Future<bool> isAuthenticated();
  Future<User> register(String name, String email, String password);
  Future<void> forgotPassword(String email, String newPassword);
}
