# Routing và entry point

## Entry point
- File chính: lib/main.dart
- Vai trò:
  - Khởi tạo Flutter binding
  - Kiểm tra token local
  - Quyết định mở màn hình đầu tiên: login, home, hoặc pin lock

## Router
- File: lib/app/routes/app_router.dart
- Dùng GoRouter
- Các route chính:
  - /login
  - /register
  - /forgot-password
  - /home
  - /categories
  - /create-category
  - /pin-lock
  - /profile
  - /profile/edit

## App bootstrap
- File: lib/app/app.dart
- Tạo MultiProvider
- Đăng ký các Provider quan trọng:
  - Auth
  - Category
  - Transaction
  - Budget
  - Profile
  - Report
  - Settings
  - Theme

## Lưu ý khi thêm route mới
- Thêm route vào AppRouter
- Nếu cần truyền tham số, dùng state.extra
- Nếu cần màn hình mới, nên đặt trong đúng feature folder tương ứng
