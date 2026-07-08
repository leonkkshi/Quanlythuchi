# Hướng dẫn phát triển cho AI và người mới

## Nguyên tắc khi chỉnh code
- Không gọi database trực tiếp từ UI.
- Luôn dùng Provider khi cần state chung.
- Nếu thêm màn hình mới, đặt trong đúng feature folder.
- Nếu thêm dữ liệu mới, cập nhật cả model và DB schema.
- Nếu thêm route mới, cập nhật AppRouter.

## Khuyến nghị đặt tên
- Provider: *Provider
- View: *Page hoặc *View
- Model: *Model
- Repository: *Repository

## Khi thêm tính năng mới
1. Xác định feature phù hợp.
2. Thêm entity/model nếu cần.
3. Thêm provider hoặc repository.
4. Thêm UI screen/widget.
5. Đăng ký route nếu cần.
6. Kiểm tra dữ liệu lưu trong DB/local state.

## Lưu ý về mock data
- Hiện tại ApiClient đang bật mock mode.
- Điều này phù hợp cho demo và development.
- Nếu cần backend thật, chỉnh ApiClient và datasource.
