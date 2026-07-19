# Module Auth

## Mục đích
Quản lý đăng nhập, đăng ký, quên mật khẩu, xác thực trạng thái đăng nhập và khóa PIN.

## Các file chính
- lib/features/auth/presentation/views/login_page.dart
- lib/features/auth/presentation/views/register_page.dart
- lib/features/auth/presentation/views/forgot_password_page.dart
- lib/features/auth/presentation/views/pin_lock_screen.dart
- lib/features/auth/application/services/auth_service_impl.dart
- lib/features/auth/data/repositories/auth_repository_impl.dart
- lib/features/auth/data/datasources/auth_local_data_source_impl.dart
- lib/features/auth/data/datasources/auth_remote_data_source_impl.dart

## Luồng đăng nhập
1. UI gọi AuthServiceImpl.login
2. Repository gọi remote/local datasource
3. ApiClient mock trả về token và user
4. Token được lưu local
5. App chuyển sang Home hoặc PIN lock

## Lưu ý
- Auth hiện dùng mock API trong ApiClient.
- Token được lưu bằng local data source.
- Nếu cần đổi sang backend thật, tập trung chỉnh ở datasource và ApiClient.
