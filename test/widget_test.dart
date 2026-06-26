import 'package:flutter_test/flutter_test.dart';
import 'package:quanlythuchi/features/auth/data/dtos/user_dto.dart';
import 'package:quanlythuchi/features/auth/data/mappers/user_mapper.dart';

void main() {
  group('UserMapper Tests', () {
    final mapper = UserMapper();

    test('should correctly map UserDto to User entity', () {
      // Arrange
      const dto = UserDto(
        id: 'u-123',
        name: 'Test User',
        email: 'test@example.com',
        avatarUrl: 'https://example.com/avatar.png',
      );

      // Act
      final entity = mapper.toEntity(dto);

      // Assert
      expect(entity.id, equals(dto.id));
      expect(entity.name, equals(dto.name));
      expect(entity.email, equals(dto.email));
      expect(entity.avatarUrl, equals(dto.avatarUrl));
    });

    test('should correctly map User entity to UserDto', () {
      // Arrange
      final entity = mapper.toEntity(const UserDto(
        id: 'u-123',
        name: 'Test User',
        email: 'test@example.com',
        avatarUrl: 'https://example.com/avatar.png',
      ));

      // Act
      final dto = mapper.toModel(entity);

      // Assert
      expect(dto.id, equals(entity.id));
      expect(dto.name, equals(entity.name));
      expect(dto.email, equals(entity.email));
      expect(dto.avatarUrl, equals(entity.avatarUrl));
    });
  });
}
