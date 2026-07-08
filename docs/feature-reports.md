# Module Reports

## Mục đích
Hiển thị báo cáo thu chi, thống kê theo tháng, theo loại danh mục và các biểu đồ.

## File chính
- lib/features/reports/application/providers/report_provider.dart
- lib/features/reports/data/repositories/report_repository.dart
- lib/features/reports/presentation/pages/reports_page.dart
- lib/features/reports/presentation/widgets/expense_pie_chart.dart
- lib/features/reports/presentation/widgets/monthly_bar_chart.dart
- lib/features/reports/presentation/widgets/category_summary_list.dart

## Luồng dữ liệu
1. ReportProvider gọi repository
2. Repository lọc giao dịch theo khoảng thời gian
3. Provider tính toán monthly summary, tổng thu, tổng chi, balance
4. UI render biểu đồ và summary cards

## Lưu ý
- Nếu cần thêm báo cáo mới, nên bổ sung ở repository trước rồi expose qua provider.
- Các widget báo cáo nên nhận dữ liệu từ Provider thay vì tự query DB.
