# Module Transaction

## Mục đích
Quản lý giao dịch thu/chi: thêm, sửa, xóa, tìm kiếm, hiển thị lịch sử.

## File chính
- lib/features/transaction/application/providers/transaction_provider.dart
- lib/features/transaction/presentation/views/transaction_input_view.dart
- lib/features/transaction/presentation/views/transaction_edit_view.dart
- lib/features/transaction/presentation/views/transaction_calendar_view.dart
- lib/features/transaction/presentation/views/transaction_report_view.dart
- lib/features/transaction/data/models/transaction_model.dart

## Provider responsibilities
- loadTransactions(userId)
- addTransaction(...)
- updateTransaction(...)
- deleteTransaction(id)
- searchTransactions(keyword)

## Lưu ý khi thêm tính năng
- Nếu cần lọc theo khoảng thời gian, nên xử lý ở provider hoặc repository.
- Nếu cần thêm trường cho giao dịch, cập nhật cả model và bảng SQLite.
- Giao diện nên chỉ dùng provider, không thao tác DB trực tiếp.
