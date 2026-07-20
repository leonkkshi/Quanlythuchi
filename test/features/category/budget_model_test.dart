import 'package:flutter_test/flutter_test.dart';
import 'package:quanlythuchi/features/category/data/models/budget_model.dart';

void main() {
  group('BudgetModel Tests', () {
    // ─── Constructor ──────────────────────────────────────────────────────────
    group('Constructor', () {
      test('should create BudgetModel with all fields', () {
        final budget = BudgetModel(
          id: 'bud-001',
          categoryId: 'cat-food',
          amount: 2000000.0,
          period: '2026-07',
          userId: 'u-001',
        );

        expect(budget.id, equals('bud-001'));
        expect(budget.categoryId, equals('cat-food'));
        expect(budget.amount, equals(2000000.0));
        expect(budget.period, equals('2026-07'));
        expect(budget.userId, equals('u-001'));
      });

      test('should support zero amount', () {
        final budget = BudgetModel(
          id: 'bud-zero',
          categoryId: 'cat-001',
          amount: 0.0,
          period: '2026-07',
          userId: 'u-001',
        );

        expect(budget.amount, equals(0.0));
      });

      test('should support large amount values', () {
        final budget = BudgetModel(
          id: 'bud-large',
          categoryId: 'cat-001',
          amount: 100000000.0, // 100 triệu
          period: '2026-07',
          userId: 'u-001',
        );

        expect(budget.amount, equals(100000000.0));
      });
    });

    // ─── fromMap ──────────────────────────────────────────────────────────────
    group('fromMap', () {
      test('should parse all fields from map correctly', () {
        final map = {
          'id': 'bud-m001',
          'category_id': 'cat-transport',
          'amount': 500000.0,
          'period': '2026-07',
          'user_id': 'u-001',
        };

        final budget = BudgetModel.fromMap(map);

        expect(budget.id, equals('bud-m001'));
        expect(budget.categoryId, equals('cat-transport'));
        expect(budget.amount, equals(500000.0));
        expect(budget.period, equals('2026-07'));
        expect(budget.userId, equals('u-001'));
      });

      test('should coerce integer amount to double', () {
        final map = {
          'id': 'bud-m002',
          'category_id': 'cat-001',
          'amount': 300000, // integer
          'period': '2026-06',
          'user_id': 'u-002',
        };

        final budget = BudgetModel.fromMap(map);

        expect(budget.amount, isA<double>());
        expect(budget.amount, equals(300000.0));
      });

      test('should parse period in YYYY-MM format', () {
        final map = {
          'id': 'bud-m003',
          'category_id': 'cat-001',
          'amount': 1000000.0,
          'period': '2026-12',
          'user_id': 'u-001',
        };

        final budget = BudgetModel.fromMap(map);
        expect(budget.period, equals('2026-12'));
      });
    });

    // ─── toMap ────────────────────────────────────────────────────────────────
    group('toMap', () {
      test('should serialize all fields to map with correct keys', () {
        final budget = BudgetModel(
          id: 'bud-s001',
          categoryId: 'cat-shopping',
          amount: 3000000.0,
          period: '2026-07',
          userId: 'u-001',
        );

        final map = budget.toMap();

        expect(map['id'], equals('bud-s001'));
        expect(map['category_id'], equals('cat-shopping'));
        expect(map['amount'], equals(3000000.0));
        expect(map['period'], equals('2026-07'));
        expect(map['user_id'], equals('u-001'));
      });

      test('should use snake_case keys for database fields', () {
        final budget = BudgetModel(
          id: 'bud-s002',
          categoryId: 'cat-001',
          amount: 500000.0,
          period: '2026-07',
          userId: 'u-001',
        );

        final map = budget.toMap();

        // snake_case (SQLite format)
        expect(map.containsKey('category_id'), isTrue);
        expect(map.containsKey('user_id'), isTrue);

        // camelCase should NOT exist
        expect(map.containsKey('categoryId'), isFalse);
        expect(map.containsKey('userId'), isFalse);
      });

      test('toMap should contain exactly 5 keys', () {
        final budget = BudgetModel(
          id: 'bud-s003',
          categoryId: 'cat-x',
          amount: 100000.0,
          period: '2026-01',
          userId: 'u-x',
        );

        final map = budget.toMap();
        expect(map.length, equals(5));
      });
    });

    // ─── Roundtrip ────────────────────────────────────────────────────────────
    group('fromMap → toMap Roundtrip', () {
      test('should preserve all data through fromMap and toMap', () {
        final originalMap = {
          'id': 'bud-rt001',
          'category_id': 'cat-health',
          'amount': 1500000.0,
          'period': '2026-08',
          'user_id': 'u-healthy',
        };

        final budget = BudgetModel.fromMap(originalMap);
        final resultMap = budget.toMap();

        expect(resultMap['id'], equals(originalMap['id']));
        expect(resultMap['category_id'], equals(originalMap['category_id']));
        expect(resultMap['amount'], equals(originalMap['amount']));
        expect(resultMap['period'], equals(originalMap['period']));
        expect(resultMap['user_id'], equals(originalMap['user_id']));
      });

      test('should preserve integer amount as double after roundtrip', () {
        final originalMap = {
          'id': 'bud-rt002',
          'category_id': 'cat-001',
          'amount': 1000000, // integer input
          'period': '2026-07',
          'user_id': 'u-001',
        };

        final budget = BudgetModel.fromMap(originalMap);
        final resultMap = budget.toMap();

        // After fromMap, amount is double; toMap keeps it double
        expect(resultMap['amount'], isA<double>());
        expect(resultMap['amount'], equals(1000000.0));
      });
    });

    // ─── Budget ID Convention ─────────────────────────────────────────────────
    group('Budget ID Convention', () {
      test('composite ID format should follow userId_categoryId_period', () {
        const userId = 'u-001';
        const categoryId = 'cat-food';
        const period = '2026-07';
        final compositeId = '${userId}_${categoryId}_$period';

        final budget = BudgetModel(
          id: compositeId,
          categoryId: categoryId,
          amount: 2000000.0,
          period: period,
          userId: userId,
        );

        expect(budget.id, equals('u-001_cat-food_2026-07'));
      });
    });
  });
}
