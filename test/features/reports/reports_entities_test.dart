import 'package:flutter_test/flutter_test.dart';
import 'package:quanlythuchi/features/reports/domain/entities/monthly_summary.dart';
import 'package:quanlythuchi/features/reports/domain/entities/category_summary.dart';
import 'package:quanlythuchi/features/reports/domain/entities/report_filter.dart';
import 'package:quanlythuchi/features/reports/domain/entities/report_transaction.dart';

void main() {
  // ─── MonthlySummary ────────────────────────────────────────────────────────
  group('MonthlySummary Tests', () {
    test('should create MonthlySummary with correct fields', () {
      const summary = MonthlySummary(
        month: 7,
        year: 2026,
        income: 15000000,
        expense: 8000000,
      );

      expect(summary.month, equals(7));
      expect(summary.year, equals(2026));
      expect(summary.income, equals(15000000));
      expect(summary.expense, equals(8000000));
    });

    test('balance should be income minus expense', () {
      const summary = MonthlySummary(
        month: 7,
        year: 2026,
        income: 15000000,
        expense: 8000000,
      );

      expect(summary.balance, equals(7000000));
    });

    test('balance should be negative when expense exceeds income', () {
      const summary = MonthlySummary(
        month: 6,
        year: 2026,
        income: 5000000,
        expense: 8000000,
      );

      expect(summary.balance, equals(-3000000));
    });

    test('balance should be zero when income equals expense', () {
      const summary = MonthlySummary(
        month: 5,
        year: 2026,
        income: 10000000,
        expense: 10000000,
      );

      expect(summary.balance, equals(0));
    });

    test('balance should be income when expense is zero', () {
      const summary = MonthlySummary(
        month: 1,
        year: 2026,
        income: 12000000,
        expense: 0,
      );

      expect(summary.balance, equals(12000000));
    });

    test('balance should be negative income when expense is zero and income negative edge-case', () {
      const summary = MonthlySummary(
        month: 12,
        year: 2025,
        income: 0,
        expense: 5000000,
      );

      expect(summary.balance, equals(-5000000));
    });

    test('should support decimal values for income and expense', () {
      const summary = MonthlySummary(
        month: 3,
        year: 2026,
        income: 15500000.50,
        expense: 7200000.25,
      );

      expect(summary.balance, closeTo(8300000.25, 0.01));
    });
  });

  // ─── CategorySummary ───────────────────────────────────────────────────────
  group('CategorySummary Tests', () {
    test('should create CategorySummary with all fields', () {
      const summary = CategorySummary(
        category: 'Ăn uống',
        amount: 3000000,
        percentage: 37.5,
      );

      expect(summary.category, equals('Ăn uống'));
      expect(summary.amount, equals(3000000));
      expect(summary.percentage, equals(37.5));
    });

    test('should support 0 percentage (no spending)', () {
      const summary = CategorySummary(
        category: 'Giải trí',
        amount: 0,
        percentage: 0,
      );

      expect(summary.amount, equals(0));
      expect(summary.percentage, equals(0));
    });

    test('should support 100 percentage (single category)', () {
      const summary = CategorySummary(
        category: 'Lương',
        amount: 20000000,
        percentage: 100,
      );

      expect(summary.percentage, equals(100));
    });

    test('percentage should be a double', () {
      const summary = CategorySummary(
        category: 'Di chuyển',
        amount: 500000,
        percentage: 12.5,
      );

      expect(summary.percentage, isA<double>());
    });

    test('should handle decimal amounts', () {
      const summary = CategorySummary(
        category: 'Sức khỏe',
        amount: 750000.50,
        percentage: 9.375,
      );

      expect(summary.amount, equals(750000.50));
      expect(summary.percentage, closeTo(9.375, 0.001));
    });
  });

  // ─── ReportPeriod & ReportPeriodLabel ─────────────────────────────────────
  group('ReportPeriod Tests', () {
    test('today should have label "Hôm nay"', () {
      expect(ReportPeriod.today.label, equals('Hôm nay'));
    });

    test('thisWeek should have label "Tuần này"', () {
      expect(ReportPeriod.thisWeek.label, equals('Tuần này'));
    });

    test('thisMonth should have label "Tháng này"', () {
      expect(ReportPeriod.thisMonth.label, equals('Tháng này'));
    });

    test('thisYear should have label "Năm nay"', () {
      expect(ReportPeriod.thisYear.label, equals('Năm nay'));
    });

    test('custom should have label "Tùy chọn"', () {
      expect(ReportPeriod.custom.label, equals('Tùy chọn'));
    });

    test('all enum values should have non-empty labels', () {
      for (final period in ReportPeriod.values) {
        expect(period.label.isNotEmpty, isTrue,
            reason: '${period.name} should have a non-empty label');
      }
    });

    test('should have exactly 5 enum values', () {
      expect(ReportPeriod.values.length, equals(5));
    });

    test('enum values should be distinguishable', () {
      final labels = ReportPeriod.values.map((p) => p.label).toSet();
      expect(labels.length, equals(ReportPeriod.values.length),
          reason: 'All labels should be unique');
    });
  });

  // ─── ReportTransaction ─────────────────────────────────────────────────────
  group('ReportTransaction Tests', () {
    // ── isIncome / isExpense ─────────────────────────────────────────────────
    group('isIncome and isExpense', () {
      test('isIncome should return true for income type', () {
        const tx = ReportTransaction(
          id: 'rt-001',
          amount: 15000000,
          type: 'income',
          category: 'Lương',
          date: '2026-07-01',
        );

        expect(tx.isIncome, isTrue);
        expect(tx.isExpense, isFalse);
      });

      test('isExpense should return true for expense type', () {
        const tx = ReportTransaction(
          id: 'rt-002',
          amount: 200000,
          type: 'expense',
          category: 'Ăn uống',
          date: '2026-07-05',
        );

        expect(tx.isExpense, isTrue);
        expect(tx.isIncome, isFalse);
      });

      test('isIncome and isExpense should not both be true', () {
        const txIncome = ReportTransaction(
          id: 'rt-003',
          amount: 5000000,
          type: 'income',
          category: 'Thưởng',
          date: '2026-07-15',
        );

        expect(txIncome.isIncome && txIncome.isExpense, isFalse);
      });
    });

    // ── fromMap ──────────────────────────────────────────────────────────────
    group('fromMap', () {
      test('should parse all fields from map correctly', () {
        final map = {
          'id': 'rt-m001',
          'title': 'Cà phê',
          'amount': 45000.0,
          'type': 'expense',
          'category_name': 'Ăn uống',
          'date': '2026-07-20',
          'note': 'Highlands Coffee',
        };

        final tx = ReportTransaction.fromMap(map);

        expect(tx.id, equals('rt-m001'));
        expect(tx.title, equals('Cà phê'));
        expect(tx.amount, equals(45000.0));
        expect(tx.type, equals('expense'));
        expect(tx.category, equals('Ăn uống'));
        expect(tx.date, equals('2026-07-20'));
        expect(tx.note, equals('Highlands Coffee'));
      });

      test('should fall back to "category" key when "category_name" is missing', () {
        final map = {
          'id': 'rt-m002',
          'amount': 100000.0,
          'type': 'income',
          'category': 'Lương',  // fallback key
          'date': '2026-07-01',
        };

        final tx = ReportTransaction.fromMap(map);
        expect(tx.category, equals('Lương'));
      });

      test('should default category to "Khác" when both keys are missing', () {
        final map = {
          'id': 'rt-m003',
          'amount': 50000.0,
          'type': 'expense',
          'date': '2026-07-10',
        };

        final tx = ReportTransaction.fromMap(map);
        expect(tx.category, equals('Khác'));
      });

      test('should handle null note from map', () {
        final map = {
          'id': 'rt-m004',
          'amount': 200000.0,
          'type': 'expense',
          'category_name': 'Mua sắm',
          'date': '2026-07-12',
          'note': null,
        };

        final tx = ReportTransaction.fromMap(map);
        expect(tx.note, isNull);
      });

      test('should handle null title from map', () {
        final map = {
          'id': 'rt-m005',
          'title': null,
          'amount': 300000.0,
          'type': 'expense',
          'category_name': 'Di chuyển',
          'date': '2026-07-08',
        };

        final tx = ReportTransaction.fromMap(map);
        expect(tx.title, isNull);
      });

      test('should coerce integer amount to double', () {
        final map = {
          'id': 'rt-m006',
          'amount': 500000, // integer
          'type': 'income',
          'category_name': 'Tiền thưởng',
          'date': '2026-07-20',
        };

        final tx = ReportTransaction.fromMap(map);
        expect(tx.amount, isA<double>());
        expect(tx.amount, equals(500000.0));
      });

      test('category_name should take priority over category fallback', () {
        final map = {
          'id': 'rt-m007',
          'amount': 100000.0,
          'type': 'expense',
          'category_name': 'Ưu tiên',  // should be used
          'category': 'Dự phòng',
          'date': '2026-07-20',
        };

        final tx = ReportTransaction.fromMap(map);
        expect(tx.category, equals('Ưu tiên'));
      });
    });

    // ── Optional fields ──────────────────────────────────────────────────────
    group('Optional fields', () {
      test('should allow null title in constructor', () {
        const tx = ReportTransaction(
          id: 'rt-opt001',
          amount: 100000,
          type: 'expense',
          category: 'Test',
          date: '2026-07-20',
        );

        expect(tx.title, isNull);
        expect(tx.note, isNull);
      });
    });
  });
}
