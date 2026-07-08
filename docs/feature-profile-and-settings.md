# Module Profile và Settings

## Profile
- File chính: lib/features/profile/application/providers/profile_provider.dart
- Mục đích: cập nhật thông tin hồ sơ người dùng, validate tên/email/số điện thoại.

## Settings
- File chính: lib/features/settings/application/providers/settings_provider.dart
- Mục đích: quản lý theme, currency, notification.

## Lưu ý khi mở rộng
- Profile và Settings có thể dùng thêm field mới bằng cách mở rộng entity và repository.
- Nếu muốn lưu cài đặt mới, nên thêm vào AppSettings và DatabaseHelper.
- UI nên dùng Provider để cập nhật state và lưu persistent data.
