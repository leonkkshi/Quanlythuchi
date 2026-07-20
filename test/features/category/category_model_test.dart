import 'package:flutter_test/flutter_test.dart';
import 'package:quanlythuchi/features/category/domain/entities/category.dart';
import 'package:quanlythuchi/features/category/data/models/category_model.dart';

void main() {
  // ─── Category Entity ───────────────────────────────────────────────────────
  group('Category Entity Tests', () {
    test('should create Category with all fields', () {
      const cat = Category(
        id: 'cat-001',
        name: 'Ăn uống',
        type: 'expense',
        iconCode: 0xe532,
        colorHex: '#FF5722',
        userId: 'u-001',
      );

      expect(cat.id, equals('cat-001'));
      expect(cat.name, equals('Ăn uống'));
      expect(cat.type, equals('expense'));
      expect(cat.iconCode, equals(0xe532));
      expect(cat.colorHex, equals('#FF5722'));
      expect(cat.userId, equals('u-001'));
    });

    test('should support income type', () {
      const cat = Category(
        id: 'cat-002',
        name: 'Lương',
        type: 'income',
        iconCode: 0xe227,
        colorHex: '#4CAF50',
        userId: 'u-001',
      );

      expect(cat.type, equals('income'));
    });
  });

  // ─── CategoryModel ─────────────────────────────────────────────────────────
  group('CategoryModel Tests', () {
    // ── fromMap ──────────────────────────────────────────────────────────────
    group('fromMap', () {
      test('should parse all fields correctly from map', () {
        final map = {
          'id': 'cat-m001',
          'name': 'Di chuyển',
          'type': 'expense',
          'icon_code': 0xe1d5,
          'color_hex': '#2196F3',
          'user_id': 'u-001',
        };

        final model = CategoryModel.fromMap(map);

        expect(model.id, equals('cat-m001'));
        expect(model.name, equals('Di chuyển'));
        expect(model.type, equals('expense'));
        expect(model.iconCode, equals(0xe1d5));
        expect(model.colorHex, equals('#2196F3'));
        expect(model.userId, equals('u-001'));
      });

      test('should parse expense type correctly', () {
        final map = {
          'id': 'cat-m002',
          'name': 'Giải trí',
          'type': 'expense',
          'icon_code': 0xe87c,
          'color_hex': '#9C27B0',
          'user_id': 'u-002',
        };

        final model = CategoryModel.fromMap(map);
        expect(model.type, equals('expense'));
      });

      test('should parse income type correctly', () {
        final map = {
          'id': 'cat-m003',
          'name': 'Tiền thưởng',
          'type': 'income',
          'icon_code': 0xe8f8,
          'color_hex': '#4CAF50',
          'user_id': 'u-003',
        };

        final model = CategoryModel.fromMap(map);
        expect(model.type, equals('income'));
      });
    });

    // ── toMap ────────────────────────────────────────────────────────────────
    group('toMap', () {
      test('should serialize all fields with correct keys', () {
        const model = CategoryModel(
          id: 'cat-s001',
          name: 'Sức khỏe',
          type: 'expense',
          iconCode: 0xe3f3,
          colorHex: '#F44336',
          userId: 'u-001',
        );

        final map = model.toMap();

        expect(map['id'], equals('cat-s001'));
        expect(map['name'], equals('Sức khỏe'));
        expect(map['type'], equals('expense'));
        expect(map['icon_code'], equals(0xe3f3));
        expect(map['color_hex'], equals('#F44336'));
        expect(map['user_id'], equals('u-001'));
      });

      test('should use snake_case keys for database fields', () {
        const model = CategoryModel(
          id: 'cat-s002',
          name: 'Test',
          type: 'expense',
          iconCode: 0xe000,
          colorHex: '#000000',
          userId: 'u-001',
        );

        final map = model.toMap();

        // snake_case keys (SQLite format)
        expect(map.containsKey('icon_code'), isTrue);
        expect(map.containsKey('color_hex'), isTrue);
        expect(map.containsKey('user_id'), isTrue);

        // camelCase keys should NOT exist
        expect(map.containsKey('iconCode'), isFalse);
        expect(map.containsKey('colorHex'), isFalse);
        expect(map.containsKey('userId'), isFalse);
      });
    });

    // ── Roundtrip ─────────────────────────────────────────────────────────────
    group('fromMap → toMap Roundtrip', () {
      test('should preserve all data through fromMap and toMap', () {
        final originalMap = {
          'id': 'cat-rt001',
          'name': 'Mua sắm',
          'type': 'expense',
          'icon_code': 0xe8cc,
          'color_hex': '#FF9800',
          'user_id': 'u-shopaholic',
        };

        final model = CategoryModel.fromMap(originalMap);
        final resultMap = model.toMap();

        expect(resultMap['id'], equals(originalMap['id']));
        expect(resultMap['name'], equals(originalMap['name']));
        expect(resultMap['type'], equals(originalMap['type']));
        expect(resultMap['icon_code'], equals(originalMap['icon_code']));
        expect(resultMap['color_hex'], equals(originalMap['color_hex']));
        expect(resultMap['user_id'], equals(originalMap['user_id']));
      });
    });

    // ── Inheritance ──────────────────────────────────────────────────────────
    group('Inheritance', () {
      test('CategoryModel should be a subtype of Category', () {
        const model = CategoryModel(
          id: 'cat-inh',
          name: 'Test',
          type: 'expense',
          iconCode: 0xe000,
          colorHex: '#FFFFFF',
          userId: 'u-1',
        );

        expect(model, isA<Category>());
      });
    });
  });
}
