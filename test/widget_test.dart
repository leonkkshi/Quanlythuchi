import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quanlythuchi/features/auth/data/dtos/user_dto.dart';
import 'package:quanlythuchi/features/auth/data/mappers/user_mapper.dart';
import 'package:quanlythuchi/features/category/data/models/budget_model.dart';
import 'package:quanlythuchi/core/theme/theme_provider.dart';

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

  group('BudgetModel Tests', () {
    test('should correctly map to and from map', () {
      final model = BudgetModel(
        id: 'b-123',
        categoryId: 'cat-123',
        amount: 500000.0,
        period: '2026-07',
        userId: 'u-123',
      );

      final map = model.toMap();
      expect(map['id'], equals('b-123'));
      expect(map['category_id'], equals('cat-123'));
      expect(map['amount'], equals(500000.0));
      expect(map['period'], equals('2026-07'));
      expect(map['user_id'], equals('u-123'));

      final fromMapModel = BudgetModel.fromMap(map);
      expect(fromMapModel.id, equals(model.id));
      expect(fromMapModel.categoryId, equals(model.categoryId));
      expect(fromMapModel.amount, equals(model.amount));
      expect(fromMapModel.period, equals(model.period));
      expect(fromMapModel.userId, equals(model.userId));
    });
  });

  group('ThemeProvider Tests', () {
    test('should correctly toggle theme and save preference', () async {
      SharedPreferences.setMockInitialValues({'is_dark': false});
      final provider = ThemeProvider();
      await Future.delayed(Duration.zero);
      expect(provider.isDarkMode, isFalse);

      await provider.toggleTheme(true);
      expect(provider.isDarkMode, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_dark'), isTrue);
    });
  });
}
