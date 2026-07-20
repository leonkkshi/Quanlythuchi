import 'package:flutter_test/flutter_test.dart';
import 'package:quanlythuchi/features/transaction/domain/entities/transaction.dart';
import 'package:quanlythuchi/features/transaction/data/models/transaction_model.dart';

void main() {
  // ─── Transaction Entity ────────────────────────────────────────────────────
  group('Transaction Entity Tests', () {
    test('should create Transaction with all required fields', () {
      const tx = Transaction(
        id: 'tx-001',
        amount: 150000,
        date: '2026-07-20',
        categoryId: 'cat-001',
        type: 'expense',
        userId: 'u-001',
      );

      expect(tx.id, equals('tx-001'));
      expect(tx.amount, equals(150000));
      expect(tx.date, equals('2026-07-20'));
      expect(tx.categoryId, equals('cat-001'));
      expect(tx.type, equals('expense'));
      expect(tx.userId, equals('u-001'));
      expect(tx.note, isNull);
    });

    test('should create Transaction with optional note', () {
      const tx = Transaction(
        id: 'tx-002',
        amount: 500000,
        date: '2026-07-21',
        note: 'Tiền điện tháng 7',
        categoryId: 'cat-002',
        type: 'expense',
        userId: 'u-001',
      );

      expect(tx.note, equals('Tiền điện tháng 7'));
    });

    test('should support income type', () {
      const tx = Transaction(
        id: 'tx-003',
        amount: 10000000,
        date: '2026-07-01',
        categoryId: 'cat-income-001',
        type: 'income',
        userId: 'u-001',
      );

      expect(tx.type, equals('income'));
    });

    test('amount should support decimal values', () {
      const tx = Transaction(
        id: 'tx-004',
        amount: 99999.99,
        date: '2026-07-20',
        categoryId: 'cat-001',
        type: 'expense',
        userId: 'u-001',
      );

      expect(tx.amount, equals(99999.99));
    });
  });

  // ─── TransactionModel ──────────────────────────────────────────────────────
  group('TransactionModel Tests', () {
    // ── fromMap ──────────────────────────────────────────────────────────────
    group('fromMap', () {
      test('should parse all fields from map correctly', () {
        final map = {
          'id': 'tx-m001',
          'amount': 250000.0,
          'date': '2026-07-15',
          'note': 'Ăn trưa',
          'category_id': 'cat-food',
          'type': 'expense',
          'user_id': 'u-001',
        };

        final model = TransactionModel.fromMap(map);

        expect(model.id, equals('tx-m001'));
        expect(model.amount, equals(250000.0));
        expect(model.date, equals('2026-07-15'));
        expect(model.note, equals('Ăn trưa'));
        expect(model.categoryId, equals('cat-food'));
        expect(model.type, equals('expense'));
        expect(model.userId, equals('u-001'));
      });

      test('should handle null note from map', () {
        final map = {
          'id': 'tx-m002',
          'amount': 100000,
          'date': '2026-07-10',
          'note': null,
          'category_id': 'cat-002',
          'type': 'income',
          'user_id': 'u-002',
        };

        final model = TransactionModel.fromMap(map);

        expect(model.note, isNull);
      });

      test('should coerce integer amount to double', () {
        final map = {
          'id': 'tx-m003',
          'amount': 500000, // integer in map
          'date': '2026-07-20',
          'note': null,
          'category_id': 'cat-003',
          'type': 'expense',
          'user_id': 'u-001',
        };

        final model = TransactionModel.fromMap(map);

        expect(model.amount, isA<double>());
        expect(model.amount, equals(500000.0));
      });
    });

    // ── toMap ────────────────────────────────────────────────────────────────
    group('toMap', () {
      test('should serialize all fields to map correctly', () {
        const model = TransactionModel(
          id: 'tx-s001',
          amount: 300000.0,
          date: '2026-07-20',
          note: 'Xăng xe',
          categoryId: 'cat-transport',
          type: 'expense',
          userId: 'u-001',
        );

        final map = model.toMap();

        expect(map['id'], equals('tx-s001'));
        expect(map['amount'], equals(300000.0));
        expect(map['date'], equals('2026-07-20'));
        expect(map['note'], equals('Xăng xe'));
        expect(map['category_id'], equals('cat-transport'));
        expect(map['type'], equals('expense'));
        expect(map['user_id'], equals('u-001'));
      });

      test('should include null note in map', () {
        const model = TransactionModel(
          id: 'tx-s002',
          amount: 200000.0,
          date: '2026-07-19',
          categoryId: 'cat-001',
          type: 'income',
          userId: 'u-002',
        );

        final map = model.toMap();

        expect(map.containsKey('note'), isTrue);
        expect(map['note'], isNull);
      });

      test('should use snake_case keys for database fields', () {
        const model = TransactionModel(
          id: 'tx-s003',
          amount: 50000.0,
          date: '2026-07-18',
          categoryId: 'cat-x',
          type: 'expense',
          userId: 'u-x',
        );

        final map = model.toMap();

        expect(map.containsKey('category_id'), isTrue);
        expect(map.containsKey('user_id'), isTrue);
        expect(map.containsKey('categoryId'), isFalse);
        expect(map.containsKey('userId'), isFalse);
      });
    });

    // ── Roundtrip ─────────────────────────────────────────────────────────────
    group('fromMap → toMap Roundtrip', () {
      test('should preserve all data through fromMap and toMap', () {
        final originalMap = {
          'id': 'tx-rt001',
          'amount': 750000.0,
          'date': '2026-06-30',
          'note': 'Học phí',
          'category_id': 'cat-edu',
          'type': 'expense',
          'user_id': 'u-student',
        };

        final model = TransactionModel.fromMap(originalMap);
        final resultMap = model.toMap();

        expect(resultMap['id'], equals(originalMap['id']));
        expect(resultMap['amount'], equals(originalMap['amount']));
        expect(resultMap['date'], equals(originalMap['date']));
        expect(resultMap['note'], equals(originalMap['note']));
        expect(resultMap['category_id'], equals(originalMap['category_id']));
        expect(resultMap['type'], equals(originalMap['type']));
        expect(resultMap['user_id'], equals(originalMap['user_id']));
      });

      test('should preserve null note through roundtrip', () {
        final originalMap = {
          'id': 'tx-rt002',
          'amount': 1000000.0,
          'date': '2026-07-01',
          'note': null,
          'category_id': 'cat-sal',
          'type': 'income',
          'user_id': 'u-001',
        };

        final model = TransactionModel.fromMap(originalMap);
        final resultMap = model.toMap();

        expect(resultMap['note'], isNull);
      });
    });

    // ── Inheritance ──────────────────────────────────────────────────────────
    group('Inheritance', () {
      test('TransactionModel should be a subtype of Transaction', () {
        const model = TransactionModel(
          id: 'tx-inh',
          amount: 100,
          date: '2026-07-20',
          categoryId: 'cat-1',
          type: 'expense',
          userId: 'u-1',
        );

        expect(model, isA<Transaction>());
      });
    });
  });
}
