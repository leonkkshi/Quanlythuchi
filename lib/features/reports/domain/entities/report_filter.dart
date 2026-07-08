// lib/features/reports/domain/entities/report_filter.dart

/// Bộ lọc thời gian cho báo cáo.
enum ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

extension ReportPeriodLabel on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.today:
        return 'Hôm nay';
      case ReportPeriod.thisWeek:
        return 'Tuần này';
      case ReportPeriod.thisMonth:
        return 'Tháng này';
      case ReportPeriod.thisYear:
        return 'Năm nay';
      case ReportPeriod.custom:
        return 'Tùy chọn';
    }
  }
}
