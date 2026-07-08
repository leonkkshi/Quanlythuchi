// lib/models/app_settings.dart

/// Cài đặt ứng dụng (theme, currency, notification).
class AppSettings {
  final String theme;
  final String currency;
  final bool notification;

  const AppSettings({
    this.theme = 'system',
    this.currency = 'VND',
    this.notification = true,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      theme: map['theme'] as String? ?? 'system',
      currency: map['currency'] as String? ?? 'VND',
      notification: (map['notification'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'currency': currency,
      'notification': notification ? 1 : 0,
    };
  }

  AppSettings copyWith({
    String? theme,
    String? currency,
    bool? notification,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      notification: notification ?? this.notification,
    );
  }
}
