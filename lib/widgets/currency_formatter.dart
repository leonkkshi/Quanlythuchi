// lib/widgets/currency_formatter.dart

/// Định dạng số tiền theo loại tiền tệ đã chọn.
class CurrencyFormatter {
  static String format(double value, String currency) {
    final absValue = value.abs();
    final formatted = _formatNumber(absValue.toInt());
    final prefix = value < 0 ? '-' : '';

    switch (currency) {
      case 'USD':
        return '$prefix\$$formatted';
      case 'EUR':
        return '$prefix€$formatted';
      case 'VND':
      default:
        return '$prefix$formatted đ';
    }
  }

  static String _formatNumber(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    var count = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}
