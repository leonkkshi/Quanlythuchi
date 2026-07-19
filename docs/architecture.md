# Kiến trúc ứng dụng

## Tổng quan
Ứng dụng là một app Flutter quản lý thu chi cá nhân, chạy offline/local-first với SQLite.

## Layer phân chia
- Presentation: các màn hình và widget trong lib/features/*/presentation
- Application: Provider và business logic trong lib/features/*/application
- Domain: entity và interface trong lib/features/*/domain
- Data: repository, datasource, model, DTO trong lib/features/*/data
- Core: shared infrastructure như theme, network, database, error handling

## Luồng dữ liệu chính
1. User mở app.
2. main.dart kiểm tra token trong local storage.
3. Nếu có token, app mở Home hoặc PIN lock screen.
4. Provider tải dữ liệu từ DatabaseHelper.
5. UI đọc state từ Provider và render giao diện.

## Điểm đáng chú ý
- App dùng Provider thay vì bloc/riverpod.
- DatabaseHelper là trung tâm dữ liệu local.
- ApiClient hiện có mock mode enabled, nên có thể dùng demo data mà không cần backend thật.
- Routing dùng GoRouter.
