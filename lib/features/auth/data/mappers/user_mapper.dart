import '../../domain/entities/user.dart';
import '../dtos/user_dto.dart';
import 'i_mapper.dart';

class UserMapper implements IMapper<UserDto, User> {
  @override
  User toEntity(UserDto model) {
    return User(
      id: model.id,
      name: model.name,
      email: model.email,
      avatarUrl: model.avatarUrl,
    );
  }

  @override
  UserDto toModel(User entity) {
    return UserDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
    );
  }
}
