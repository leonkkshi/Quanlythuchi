import '../dtos/user_dto.dart';

abstract class IAuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  Future<void> saveUser(UserDto user);
  Future<UserDto?> getUser();
  Future<void> deleteUser();
  
  Future<void> clear();
}
