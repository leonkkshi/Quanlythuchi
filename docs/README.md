# Tài liệu codebase Quản Lý Thu Chi

Tài liệu này được tạo để giúp AI hoặc người mới đọc codebase nhanh hơn, không cần đọc toàn bộ source để hiểu hệ thống.

## Mục tiêu
- Giúp hiểu cấu trúc app nhanh.
- Giúp thêm tính năng mới mà không lạc hướng.
- Giúp giảm token khi đọc code bằng AI.

## Cấu trúc tổng quan
- App chính: lib/main.dart
- Khởi tạo router và providers: lib/app/app.dart
- Routing: lib/app/routes/app_router.dart
- Core: lib/core/
- Features: lib/features/
- Database: lib/core/database/database_helper.dart

## Các module chính
- Auth: đăng nhập, đăng ký, quên mật khẩu, PIN lock
- Home: dashboard tổng quan
- Transaction: thêm/sửa/xóa giao dịch, lọc, báo cáo giao dịch
- Category: quản lý danh mục thu/chi
- Reports: báo cáo và biểu đồ
- Profile: hồ sơ người dùng
- Settings: cài đặt ứng dụng

## Công nghệ sử dụng
- Flutter
- Provider
- GoRouter
- sqflite
- shared_preferences
- fl_chart
- intl

## Điểm cần nhớ khi mở rộng
- Dữ liệu chính đang dùng SQLite local database.
- Hầu hết state được quản lý bằng Provider.
- UI và logic được chia theo feature.
- Các màn hình thường đọc dữ liệu qua Provider, không gọi database trực tiếp từ UI.
